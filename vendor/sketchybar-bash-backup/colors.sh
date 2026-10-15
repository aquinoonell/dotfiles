#!/usr/bin/env bash
# SketchyBar palette — Felix-style tokens, filled by `theme` / theme-picker.

export TRANSPARENT=0x00000000
export BLACK=0xff181926
export WHITE=0xffcad3f5
export GREY=0xff939ab7
export RED=0xffed8796
export GREEN=0xffa6da95
export BLUE=0xff8aadf4
export YELLOW=0xffeed49f
export ORANGE=0xfff5a97f

# Defaults until cache exists (Felix catppuccin-ish)
export BAR_COLOR=0xa024273a
export ICON_COLOR=$WHITE
export LABEL_COLOR=$WHITE
export BACKGROUND_1=0x903c3e4f
export BACKGROUND_2=0x90494d64
export POPUP_BACKGROUND_COLOR=0xff24273a
export POPUP_BORDER_COLOR=$WHITE
export SHADOW_COLOR=$BLACK
export BATTERY_COLOR_NORMAL=$WHITE
export BATTERY_COLOR_WARNING=$YELLOW
export BATTERY_COLOR_LOW=$ORANGE
export BATTERY_COLOR_CRITICAL=$RED
export BATTERY_COLOR_CHARGING=$GREEN

CACHE="$HOME/.cache/dotfiles/sketchybar-colors.sh"
if [[ -f "$CACHE" ]]; then
  # shellcheck disable=SC1090
  source "$CACHE"
fi

# Aliases for plugins / theme cache
export TEXT_PRIMARY="${TEXT_PRIMARY:-$WHITE}"
export TEXT_MUTED="${TEXT_MUTED:-$GREY}"
export DEFAULT_ICON_COLOR="${DEFAULT_ICON_COLOR:-$ICON_COLOR}"
export DEFAULT_LABEL_COLOR="${DEFAULT_LABEL_COLOR:-$LABEL_COLOR}"
export FOREGROUND_COLOR="${FOREGROUND_COLOR:-$WHITE}"
export MUTED_COLOR="${MUTED_COLOR:-$GREY}"
export ACCENT_COLOR="${ACCENT_COLOR:-$BLUE}"
export BACKGROUND_COLOR="${BACKGROUND_COLOR:-$BAR_COLOR}"
export CLOCK_COLOR="${CLOCK_COLOR:-$WHITE}"
export VOLUME_COLOR="${VOLUME_COLOR:-$GREY}"
export SPACE_OCCUPIED="${SPACE_OCCUPIED:-$WHITE}"
export SPACE_INACTIVE_COLOR="${SPACE_INACTIVE_COLOR:-$GREY}"
export SPACE_ACTIVE_COLOR="${SPACE_ACTIVE_COLOR:-$RED}"
