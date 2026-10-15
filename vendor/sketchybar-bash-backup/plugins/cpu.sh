#!/bin/bash
# CPU % for SketchyBar (Sora desktop layout).

CONFIG_DIR="${CONFIG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

# One-shot sample from top; falls back to ps if needed.
cpu=$(top -l 2 -n 0 -s 0 2>/dev/null \
  | awk '/CPU usage/ {gsub(/%/,"",$3); print int($3+0.5); exit}')

if [[ -z "$cpu" ]]; then
  cpu=$(ps -A -o %cpu 2>/dev/null | awk '{s+=$1} END {print int(s+0.5)}')
fi
[[ -z "$cpu" ]] && cpu=0

color="${ACCENT_COLOR:-$BLUE}"
if ((cpu >= 85)); then
  color="${RED}"
elif ((cpu >= 60)); then
  color="${ORANGE:-$YELLOW}"
fi

sketchybar --set "${NAME:-cpu}" \
  icon="􀧓" \
  icon.color="$color" \
  label="${cpu}%" \
  label.color="$color"
