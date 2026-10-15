#!/bin/bash
# Date pill — "Sun 25 Jul"

CONFIG_DIR="${CONFIG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

sketchybar --set "${NAME:-calendar}" \
  icon=􀉉 \
  label="$(date '+%a %d %b')" \
  icon.color="${TEXT_MUTED:-$GREY}" \
  label.color="${TEXT_MUTED:-$GREY}" \
  icon.drawing=on
