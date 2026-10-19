#!/usr/bin/env bash
# Fast project → session picker (project roots only, no deep find).
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

if [[ $# -eq 1 ]]; then
  selected=$1
else
  selected=$(
    {
      find "$HOME/Desktop/dev" -mindepth 1 -maxdepth 1 -type d 2>/dev/null
      find "$HOME/Documents" -mindepth 1 -maxdepth 1 -type d 2>/dev/null
      find "$HOME" -mindepth 1 -maxdepth 1 -type d 2>/dev/null
      command -v zoxide >/dev/null && zoxide query -l 2>/dev/null | head -40
    } \
      | grep -Ev '/(\.git|node_modules|target|\.venv|venv|dist|\.next)(/|$)' \
      | sed "s|^$HOME/||" \
      | awk 'NF && !seen[$0]++' \
      | fzf --reverse --prompt="project> "
  )
  [[ -n "${selected:-}" ]] && selected="$HOME/$selected"
fi

[[ -z "${selected:-}" ]] && exit 0
[[ -d "$selected" ]] || exit 0

selected_name=$(basename "$selected" | tr '. ' '__')

if [[ -z "${TMUX:-}" ]] && ! pgrep -x tmux >/dev/null; then
  tmux new-session -s "$selected_name" -c "$selected"
  exit 0
fi

if ! tmux has-session -t="=$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"
fi

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$selected_name"
else
  tmux attach -t "$selected_name"
fi
