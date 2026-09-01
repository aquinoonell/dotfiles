#!/usr/bin/env bash
# Fix SearXNG CAPTCHA / no-results issue on homelab.
# Run on the host that serves http://192.168.1.168:8080 (as root).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDE_SRC="${SCRIPT_DIR}/searxng-settings-override.yml"
OVERRIDE_TMP=""

write_override() {
  cat >"$1" <<'YAML'
use_default_settings: true

search:
  max_ban_time_on_fail: 120
  suspended_times:
    SearxEngineAccessDenied: 86400
    SearxEngineCaptcha: 86400
    SearxEngineTooManyRequests: 3600

engines:
  - name: duckduckgo
    disabled: true
  - name: startpage
    disabled: true
  - name: google
    disabled: true
  - name: brave
    disabled: true
  - name: bing
    disabled: false
    weight: 2.0
  - name: wiby
    disabled: false
    weight: 1.5
  - name: wikipedia
    disabled: false
    weight: 1.0
  - name: seznam
    disabled: false
    weight: 0.5
  - name: mojeek
    disabled: false
    weight: 0.8
  - name: qwant
    disabled: false
    weight: 0.8
  - name: yahoo
    disabled: false
    weight: 0.5
  - name: presearch
    disabled: false
    weight: 0.5
YAML
}

if [[ ! -f "$OVERRIDE_SRC" ]]; then
  OVERRIDE_TMP="$(mktemp)"
  OVERRIDE_SRC="$OVERRIDE_TMP"
  write_override "$OVERRIDE_SRC"
  trap 'rm -f "$OVERRIDE_TMP"' EXIT
fi
SETTINGS_PATHS=(
  /etc/searxng/settings.yml
  /opt/searxng/settings.yml
  /usr/local/searxng/settings.yml
)

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ -f "$OVERRIDE_SRC" ]] || die "Missing $OVERRIDE_SRC"

log "Outbound IP (what search engines see):"
curl -fsS --max-time 8 https://ifconfig.me/ip || curl -fsS --max-time 8 https://api.ipify.org || true
echo

SETTINGS=""
for path in "${SETTINGS_PATHS[@]}"; do
  if [[ -f "$path" ]]; then
    SETTINGS="$path"
    break
  fi
done

if [[ -z "$SETTINGS" ]]; then
  log "settings.yml not on disk — checking Docker..."
  CONTAINER="$(docker ps --format '{{.Names}}' | grep -Ei 'searx' | head -1 || true)"
  [[ -n "$CONTAINER" ]] || die "No SearXNG container found. Is Docker running?"

  log "Found container: $CONTAINER"
  SETTINGS_IN_CONTAINER="$(docker exec "$CONTAINER" sh -c 'for p in /etc/searxng/settings.yml /usr/local/searxng/searx/settings.yml; do [ -f "$p" ] && echo "$p" && exit 0; done; exit 1')"
  BACKUP="settings.yml.bak.$(date +%Y%m%d-%H%M%S)"
  docker exec "$CONTAINER" cp "$SETTINGS_IN_CONTAINER" "$(dirname "$SETTINGS_IN_CONTAINER")/$BACKUP"
  docker cp "$OVERRIDE_SRC" "$CONTAINER:$SETTINGS_IN_CONTAINER"
  log "Backed up to $BACKUP inside container; applied override."
  docker restart "$CONTAINER"
  log "Restarted $CONTAINER"
else
  BACKUP="${SETTINGS}.bak.$(date +%Y%m%d-%H%M%S)"
  cp "$SETTINGS" "$BACKUP"
  cp "$OVERRIDE_SRC" "$SETTINGS"
  log "Backed up to $BACKUP; applied override at $SETTINGS"

  if systemctl is-active --quiet searxng 2>/dev/null; then
    systemctl restart searxng
    log "Restarted searxng systemd service"
  elif docker ps --format '{{.Names}}' | grep -Eiq 'searx'; then
    docker restart "$(docker ps --format '{{.Names}}' | grep -Ei 'searx' | head -1)"
    log "Restarted SearXNG Docker container"
  else
    log "Restart SearXNG manually if searches still fail."
  fi
fi

log "Waiting for SearXNG..."
for _ in $(seq 1 20); do
  if curl -fsS --max-time 2 "http://127.0.0.1:8080/" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

log "Smoke test (should return results, no CAPTCHA in engine messages):"
curl -fsS --max-time 15 -X POST "http://127.0.0.1:8080/search" -d "q=rust+programming" \
  | grep -E 'class="result |response-error|CAPTCHA' | head -20 || true

log "Done. Retry a search in Zen Browser."
