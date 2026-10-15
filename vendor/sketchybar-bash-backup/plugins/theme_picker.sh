#!/bin/bash
# Open the interactive theme picker in Kitty.

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/dotfiles/bin:${PATH:-}"

if command -v kitty &>/dev/null; then
  kitty --single-instance --title "theme-picker" \
    -o remember_window_size=no \
    -o initial_window_width=900 \
    -o initial_window_height=520 \
    -d "$HOME" \
    "$HOME/dotfiles/bin/theme-picker" &
  disown
elif command -v osascript &>/dev/null; then
  osascript <<'EOF' >/dev/null 2>&1 &
tell application "Terminal"
  do script "$HOME/dotfiles/bin/theme-picker; exit"
  activate
end tell
EOF
fi
