#!/bin/bash
# Battery % with SF Symbol — cyan when healthy (screenshot style).

CONFIG_DIR="${CONFIG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"
# shellcheck disable=SC1091
source "$CONFIG_DIR/icons.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ -z "$PERCENTAGE" ]; then
  sketchybar --set "${NAME:-battery}" drawing=off
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON=$BATTERY_100 ;;
  [6-8][0-9]) ICON=$BATTERY_75 ;;
  [3-5][0-9]) ICON=$BATTERY_50 ;;
  [1-2][0-9]) ICON=$BATTERY_25 ;;
  *) ICON=$BATTERY_0 ;;
esac

COLOR="${ACCENT_COLOR:-$BLUE}"
if [ -n "$CHARGING" ]; then
  ICON=$BATTERY_CHARGING
elif [ "${PERCENTAGE}" -le 20 ]; then
  COLOR="${BATTERY_COLOR_CRITICAL:-$RED}"
elif [ "${PERCENTAGE}" -le 35 ]; then
  COLOR="${BATTERY_COLOR_WARNING:-$YELLOW}"
fi

sketchybar --set "${NAME:-battery}" \
  drawing=on \
  icon="$ICON" \
  icon.color="$COLOR" \
  label="${PERCENTAGE}%" \
  label.color="$COLOR"
