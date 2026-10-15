#!/bin/bash
# Wi-Fi icon only (matches the screenshot — no SSID label).

CONFIG_DIR="${CONFIG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/sbin:/sbin:$PATH"

ICON_ON="􀙇"
ICON_OFF="􀙈"
color="${ACCENT_COLOR:-$BLUE}"
icon="$ICON_OFF"

ip=$(ipconfig getifaddr en0 2>/dev/null || true)
if [[ -n "$ip" ]]; then
  icon="$ICON_ON"
else
  # Wired fallback
  while IFS= read -r iface; do
    [[ -z "$iface" ]] && continue
    if ipconfig getifaddr "$iface" >/dev/null 2>&1; then
      icon="􀤆"
      break
    fi
  done <<EOF
$(networksetup -listallhardwareports 2>/dev/null \
  | awk '/Hardware Port:/{p=$0} /Device:/{d=$2; if (p !~ /Wi-Fi|Thunderbolt Bridge/) print d}')
EOF
  [[ "$icon" == "$ICON_OFF" ]] && color="${TEXT_MUTED:-$GREY}"
fi

sketchybar --set "${NAME:-wifi}" \
  icon="$icon" \
  icon.color="$color" \
  label.drawing=off
