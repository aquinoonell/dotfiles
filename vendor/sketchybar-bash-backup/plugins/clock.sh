#!/bin/bash
# Time pill — "12:17 am"

CONFIG_DIR="${CONFIG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

sketchybar --set "${NAME:-clock}" \
  icon=􀐫 \
  label="$(date '+%-I:%M %p' | tr '[:upper:]' '[:lower:]')" \
  icon.color="${ACCENT_COLOR:-$BLUE}" \
  label.color="${ACCENT_COLOR:-$BLUE}"
