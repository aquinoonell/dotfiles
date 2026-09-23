#!/usr/bin/env bash
# Install userspace WireGuard (wireproxy) on CT 103 so only SearXNG
# outbound HTTP uses a VPN exit. LAN and Tailscale stay on eth0.
#
# Default peer: Cloudflare WARP via wgcf (no account required).
# To use Mullvad/IVPN later: replace /etc/wireproxy/wg0.conf on the CT
# with a standard WireGuard peer config (no PostUp/iptables) and
# `systemctl restart wireproxy`.
#
# Run from Mac: ./setup-searxng-egress.sh
set -euo pipefail

PROXMOX_HOST="${PROXMOX_HOST:-proxmox}"
CT_ID="103"
WIREPROXY_VER="${WIREPROXY_VER:-1.1.3}"
WGCF_VER="${WGCF_VER:-2.2.32}"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

log "Installing SearXNG WireGuard egress on CT $CT_ID..."

ssh "root@${PROXMOX_HOST}" "pct exec $CT_ID -- bash -s" <<EOF
set -euo pipefail
export PATH="/usr/local/bin:/usr/bin:/bin:\$PATH"
export LC_ALL=C
WIREPROXY_VER='$WIREPROXY_VER'
WGCF_VER='$WGCF_VER'
CONF_DIR=/etc/wireproxy
BIN_DIR=/usr/local/bin

docker0_ip() {
  ip -4 addr show docker0 2>/dev/null | awk '/inet / {print \$2}' | cut -d/ -f1
}

install_bins() {
  mkdir -p "\$CONF_DIR" /tmp/wg-install
  cd /tmp/wg-install

  if ! command -v wireproxy >/dev/null 2>&1; then
    echo "==> downloading wireproxy \$WIREPROXY_VER"
    curl -fsSL -o wireproxy.tar.gz \\
      "https://github.com/windtf/wireproxy/releases/download/v\${WIREPROXY_VER}/wireproxy_linux_amd64.tar.gz"
    tar -xzf wireproxy.tar.gz
    install -m 0755 wireproxy "\$BIN_DIR/wireproxy"
  fi

  if ! command -v wgcf >/dev/null 2>&1; then
    echo "==> downloading wgcf \$WGCF_VER"
    curl -fsSL -o "\$BIN_DIR/wgcf" \\
      "https://github.com/ViRb3/wgcf/releases/download/v\${WGCF_VER}/wgcf_\${WGCF_VER}_linux_amd64"
    chmod 0755 "\$BIN_DIR/wgcf"
  fi
}

sanitize_wg_conf() {
  # Drop wg-quick-only keys that wireproxy does not implement.
  grep -vE '^(DNS|Table|SaveConfig|PostUp|PostDown|PreUp|PreDown)[[:space:]]*=' "\$1" > "\$1.sanitized"
  mv "\$1.sanitized" "\$1"
}

ensure_warp_peer() {
  if [[ -s "\$CONF_DIR/wg0.conf" ]]; then
    echo "==> using existing \$CONF_DIR/wg0.conf"
    sanitize_wg_conf "\$CONF_DIR/wg0.conf"
    return
  fi

  echo "==> registering Cloudflare WARP (wgcf) — swap this file for Mullvad later"
  cd "\$CONF_DIR"
  if [[ ! -s wgcf-account.toml ]]; then
    "\$BIN_DIR/wgcf" register --accept-tos
  fi
  "\$BIN_DIR/wgcf" generate
  cp -f wgcf-profile.conf "\$CONF_DIR/wg0.conf"
  sanitize_wg_conf "\$CONF_DIR/wg0.conf"
  chmod 600 "\$CONF_DIR/wg0.conf" "\$CONF_DIR/wgcf-account.toml" "\$CONF_DIR/wgcf-profile.conf" 2>/dev/null || true
}

write_wireproxy_conf() {
  local socks_ip
  socks_ip="\$(docker0_ip)"
  [[ -n "\$socks_ip" ]] || socks_ip=172.17.0.1

  cat > "\$CONF_DIR/wireproxy.conf" <<CONF
WGConfig = \$CONF_DIR/wg0.conf

[Socks5]
BindAddress = \${socks_ip}:1080
CONF
  chmod 600 "\$CONF_DIR/wireproxy.conf"
  echo "==> SOCKS5 will bind \${socks_ip}:1080"
}

write_unit() {
  cat > /etc/systemd/system/wireproxy.service <<'UNIT'
[Unit]
Description=Userspace WireGuard SOCKS5 (SearXNG egress only)
After=docker.service network-online.target
Wants=network-online.target
Requires=docker.service

[Service]
Type=simple
ExecStart=/usr/local/bin/wireproxy -c /etc/wireproxy/wireproxy.conf
Restart=on-failure
RestartSec=3
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
UNIT
  systemctl daemon-reload
  systemctl enable --now wireproxy.service
}

verify_proxy() {
  local socks_ip
  socks_ip="\$(docker0_ip)"
  [[ -n "\$socks_ip" ]] || socks_ip=172.17.0.1

  echo "==> waiting for SOCKS5"
  for i in \$(seq 1 20); do
    if ss -lnt | grep -q ":1080"; then
      break
    fi
    sleep 1
  done
  systemctl --no-pager --full status wireproxy.service | sed -n '1,20p'

  echo "==> direct egress:"
  curl -4 -fsS --max-time 8 https://ifconfig.me || true
  echo
  echo "==> SOCKS egress:"
  curl -4 -fsS --max-time 12 --proxy "socks5h://\${socks_ip}:1080" https://ifconfig.me || {
    echo "ERROR: SOCKS proxy did not return an IP"
    journalctl -u wireproxy -n 40 --no-pager
    exit 1
  }
  echo
}

apt-get update -qq
apt-get install -y -qq curl ca-certificates iproute2 >/dev/null
install_bins
ensure_warp_peer
write_wireproxy_conf
write_unit
verify_proxy
echo "==> wireproxy ready"
EOF
