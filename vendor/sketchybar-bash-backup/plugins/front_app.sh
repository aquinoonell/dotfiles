#!/bin/sh
# Focused app name (Rift → SketchyBar INFO → System Events).

# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

app=""
if [ "$SENDER" = "front_app_switched" ] && [ -n "$INFO" ]; then
  app="$INFO"
fi

if [ -z "$app" ] && command -v rift-cli >/dev/null && command -v jq >/dev/null; then
  app=$(rift-cli query windows 2>/dev/null \
    | jq -r '[.[] | select(.is_focused == true)][0].app_name // empty' 2>/dev/null)
fi

if [ -z "$app" ]; then
  app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null || true)
fi

sketchybar --set "${NAME:-front_app}" \
  label="${app:-}" \
  label.color="$DEFAULT_LABEL_COLOR"
