#!/bin/bash
# Rebuild network popup: current link, preferred Wi-Fi networks, open system Wi-Fi.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/sbin:/sbin:$PATH"
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

PARENT="network"
WIFI_DEV="en0"

# Clear previous popup rows
for i in $(seq 0 64); do
  sketchybar --remove "network.row.$i" 2>/dev/null || true
done

add_row() {
  local idx="$1" label="$2" color="$3" script="$4"
  local name="network.row.$idx"
  sketchybar --add item "$name" popup.$PARENT \
    --set "$name" \
      icon.drawing=off \
      label="$label" \
      label.color="$color" \
      label.font="SF Pro:Medium:12.0" \
      label.max_chars=36 \
      padding_left=10 \
      padding_right=10 \
      click_script="$script"
}

i=0

# --- Current connection status ---
ether_if=""
while IFS= read -r iface; do
  [[ -z "$iface" ]] && continue
  ip=$(ipconfig getifaddr "$iface" 2>/dev/null || true)
  if [[ -n "$ip" ]]; then
    ether_if="$iface"
    break
  fi
done < <(
  networksetup -listallhardwareports 2>/dev/null \
    | awk '/Hardware Port:/{p=$0} /Device:/{d=$2; if (p !~ /Wi-Fi|Thunderbolt Bridge/) print d}'
)

current_ssid=$(networksetup -getairportnetwork "$WIFI_DEV" 2>/dev/null | sed 's/Current Wi-Fi Network: //')
[[ "$current_ssid" == *"not associated"* ]] && current_ssid=""

if [[ -n "$ether_if" ]]; then
  add_row "$i" "● Ethernet connected" "$ACCENT_COLOR" "sketchybar --set $PARENT popup.drawing=off"
  i=$((i + 1))
fi
if [[ -n "$current_ssid" ]]; then
  add_row "$i" "● Wi-Fi: $current_ssid" "$ACCENT_COLOR" "sketchybar --set $PARENT popup.drawing=off"
  i=$((i + 1))
fi

add_row "$i" "──────── known networks ────────" "$MUTED_COLOR" "sketchybar --set $PARENT popup.drawing=off"
i=$((i + 1))

# Preferred / known networks (keychain) — joining works without prompting for saved ones
while IFS= read -r ssid; do
  [[ -z "$ssid" ]] && continue
  [[ "$ssid" == "Preferred networks on "* ]] && continue
  ssid="${ssid#"${ssid%%[![:space:]]*}"}" # trim
  [[ -z "$ssid" ]] && continue

  if [[ "$ssid" == "$current_ssid" ]]; then
    color="$ACCENT_COLOR"
    prefix="● "
  else
    color="$FOREGROUND_COLOR"
    prefix="○ "
  fi
  safe=${ssid//\"/\\\"}
  add_row "$i" "${prefix}${ssid}" "$color" \
    "networksetup -setairportnetwork $WIFI_DEV \"$safe\" >/dev/null 2>&1; sketchybar --set $PARENT popup.drawing=off; sleep 1; sketchybar --trigger wifi_change"
  i=$((i + 1))
done < <(networksetup -listpreferredwirelessnetworks "$WIFI_DEV" 2>/dev/null)

add_row "$i" "──────── actions ────────" "$MUTED_COLOR" "sketchybar --set $PARENT popup.drawing=off"
i=$((i + 1))

# Opens System Settings → Wi‑Fi (shows live nearby networks)
add_row "$i" "Open Wi‑Fi settings…" "$FOREGROUND_COLOR" \
  "open 'x-apple.systempreferences:com.apple.wifi-settings-extension' 2>/dev/null; sketchybar --set $PARENT popup.drawing=off"
i=$((i + 1))

# Also try to pop the native Control Center Wi‑Fi menu when possible
add_row "$i" "Show Wi‑Fi menu…" "$FOREGROUND_COLOR" \
  "$CONFIG_DIR/plugins/open_wifi_menu.sh; sketchybar --set $PARENT popup.drawing=off"

sketchybar --set "$PARENT" \
  popup.drawing=toggle \
  popup.horizontal=off \
  popup.align=right \
  popup.background.color="$BAR_COLOR" \
  popup.background.corner_radius=8 \
  popup.background.border_width=1 \
  popup.background.border_color="$MUTED_COLOR" \
  popup.blur_radius=20
