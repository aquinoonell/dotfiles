#!/bin/bash
# Active Rift layout icon (SF Pro geometric — reliable, no Nerd Font tofu).
# Click opens Rift mission-control overview (see sketchybarrc click_script).

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Accordion / tiled panes vs stacked layers (Unicode in SF Pro)
ICON_ACCORDION="▥" # vertical panes — bsp
ICON_STACK="▤"     # horizontal layers — stack
ICON_SCROLL="☰"
ICON_FLOAT="◻"

mode=""
if command -v rift-cli &>/dev/null && command -v jq &>/dev/null; then
  mode=$(rift-cli query workspaces 2>/dev/null \
    | jq -r '[.[] | select(.is_active == true)][0].layout_mode // empty' 2>/dev/null)
fi

case "$mode" in
  stack|master_stack) icon="$ICON_STACK" ;;
  scrolling)          icon="$ICON_SCROLL" ;;
  floating)           icon="$ICON_FLOAT" ;;
  bsp|traditional|"") icon="$ICON_ACCORDION" ;;
  *)                  icon="$ICON_ACCORDION" ;;
esac

sketchybar --set "${NAME:-layout}" \
  icon="$icon" \
  icon.font="SF Pro:Bold:15.0" \
  icon.color="$ACCENT_COLOR" \
  label.drawing=off
