#!/usr/bin/env bash
# Rift workspaces → numbered pills inside the transparent-bar spaces cluster.

CONFIG_DIR="${CONFIG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$CONFIG_DIR/colors.sh"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v rift-cli >/dev/null || ! command -v jq >/dev/null; then
  exit 0
fi

json=$(rift-cli query workspaces 2>/dev/null) || exit 0
[[ -z "$json" || "$json" == "null" ]] && exit 0

args=()
while IFS=$'\t' read -r index ws_name is_active window_count; do
  [[ -z "$index" ]] && continue
  name="space.$index"
  sid=$((index + 1))

  # Show first 3 always; otherwise only occupied / active
  if [[ "$is_active" != "true" && "${window_count:-0}" -eq 0 && "$index" -gt 2 ]]; then
    args+=(--set "$name" drawing=off)
    continue
  fi

  if [[ "$is_active" == "true" ]]; then
    args+=(--set "$name"
      drawing=on
      icon="$sid"
      icon.font="SF Pro:Heavy:13.0"
      icon.color="${ACCENT_COLOR:-$BLUE}"
      icon.padding_left=10
      icon.padding_right=10
      label.drawing=off
      background.drawing=on
      background.color="${BACKGROUND_2:-0x90222838}"
      background.corner_radius=7
      background.height=22)
  else
    color="${TEXT_MUTED:-$GREY}"
    [[ "${window_count:-0}" -gt 0 ]] && color="${TEXT_PRIMARY:-$WHITE}"
    args+=(--set "$name"
      drawing=on
      icon="$sid"
      icon.font="SF Pro:Bold:13.0"
      icon.color="$color"
      icon.padding_left=8
      icon.padding_right=8
      label.drawing=off
      background.drawing=off)
  fi
done < <(echo "$json" | jq -r '
  .[] | [.index, .name, .is_active, .window_count] | @tsv')

if ((${#args[@]} > 0)); then
  sketchybar "${args[@]}"
fi
