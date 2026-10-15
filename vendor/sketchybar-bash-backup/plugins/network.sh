#!/bin/sh
# Ethernet / Wi-Fi indicator (Hack Nerd Font).

# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/sbin:/sbin:$PATH"

ICON_WIFI="󰖩"
ICON_ETHER="󰈀"
ICON_OFF="󰖪"

label=""
icon="$ICON_OFF"
color="$TEXT_MUTED"

ether_if=""
while IFS= read -r iface; do
  [ -z "$iface" ] && continue
  ip=$(ipconfig getifaddr "$iface" 2>/dev/null || true)
  if [ -n "$ip" ]; then
    ether_if="$iface"
    break
  fi
done <<EOF
$(networksetup -listallhardwareports 2>/dev/null \
  | awk '/Hardware Port:/{p=$0} /Device:/{d=$2; if (p !~ /Wi-Fi|Thunderbolt Bridge/) print d}')
EOF

if [ -n "$ether_if" ]; then
  icon="$ICON_ETHER"
  label="Ethernet"
  color="$TEXT_PRIMARY"
else
  wifi_ip=$(ipconfig getifaddr en0 2>/dev/null || true)
  ssid=$(networksetup -getairportnetwork en0 2>/dev/null | sed 's/Current Wi-Fi Network: //')
  case "$ssid" in
    *"not associated"*) ssid="" ;;
  esac
  if [ -n "$wifi_ip" ] || [ -n "$ssid" ]; then
    icon="$ICON_WIFI"
    label="${ssid:-Wi-Fi}"
    color="$TEXT_PRIMARY"
  else
    label="Offline"
    color="$TEXT_MUTED"
  fi
fi

# Truncate long SSIDs
case "$label" in
  ?????????????????*) label="$(printf '%.15s' "$label")…" ;;
esac

sketchybar --set "${NAME:-network}" \
  icon="$icon" \
  icon.color="$color" \
  label="$label" \
  label.color="$color"
