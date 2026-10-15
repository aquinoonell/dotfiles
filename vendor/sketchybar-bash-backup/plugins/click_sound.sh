#!/bin/bash
# Rebuild volume popup with available audio output devices, then toggle it.

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

PARENT="volume"

# Clear previous popup rows
for i in $(seq 0 32); do
  sketchybar --remove "volume.device.$i" 2>/dev/null || true
done

if ! command -v SwitchAudioSource >/dev/null; then
  sketchybar --add item volume.device.0 popup.$PARENT \
    --set volume.device.0 \
      icon.drawing=off \
      label="Install switchaudio-osx" \
      label.color="$MUTED_COLOR" \
      click_script="sketchybar --set $PARENT popup.drawing=off"
  sketchybar --set "$PARENT" popup.drawing=toggle popup.background.color="$BAR_COLOR" popup.background.corner_radius=6
  exit 0
fi

current=$(SwitchAudioSource -c -t output 2>/dev/null || true)
i=0
while IFS= read -r device; do
  [[ -z "$device" ]] && continue
  name="volume.device.$i"
  # Highlight the active output
  if [[ "$device" == "$current" ]]; then
    color="$ACCENT_COLOR"
    prefix="● "
  else
    color="$FOREGROUND_COLOR"
    prefix="○ "
  fi
  # Escape quotes for click_script
  safe=${device//\"/\\\"}
  sketchybar --add item "$name" popup.$PARENT \
    --set "$name" \
      icon.drawing=off \
      label="${prefix}${device}" \
      label.color="$color" \
      label.font="SF Pro:Medium:12.0" \
      padding_left=10 \
      padding_right=10 \
      click_script="SwitchAudioSource -s \"$safe\" -t output >/dev/null; sketchybar --set $PARENT popup.drawing=off; sketchybar --trigger volume_change"
  i=$((i + 1))
done < <(SwitchAudioSource -a -t output 2>/dev/null)

if [[ $i -eq 0 ]]; then
  sketchybar --add item volume.device.0 popup.$PARENT \
    --set volume.device.0 \
      icon.drawing=off \
      label="No output devices" \
      label.color="$MUTED_COLOR"
fi

sketchybar --set "$PARENT" \
  popup.drawing=toggle \
  popup.horizontal=off \
  popup.align=right \
  popup.background.color="$BAR_COLOR" \
  popup.background.corner_radius=8 \
  popup.background.border_width=1 \
  popup.background.border_color="$MUTED_COLOR" \
  popup.blur_radius=20
