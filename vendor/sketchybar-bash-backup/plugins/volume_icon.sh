#!/bin/bash
# Volume icon (no slider) — screenshot style.

CONFIG_DIR="${CONFIG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"
# shellcheck disable=SC1091
source "$CONFIG_DIR/icons.sh"

vol=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo 50)
muted=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo false)

if [[ "$muted" == "true" ]] || [[ "$vol" -eq 0 ]]; then
  icon="$VOLUME_0"
elif [[ "$vol" -lt 30 ]]; then
  icon="$VOLUME_10"
elif [[ "$vol" -lt 60 ]]; then
  icon="$VOLUME_33"
elif [[ "$vol" -lt 90 ]]; then
  icon="$VOLUME_66"
else
  icon="$VOLUME_100"
fi

sketchybar --set "${NAME:-volume_icon}" \
  icon="$icon" \
  icon.color="${ACCENT_COLOR:-$BLUE}" \
  label.drawing=off
