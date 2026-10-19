#!/usr/bin/env bash
# Fast session switcher. Preview off by default — press ? to toggle.
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
current=$(tmux display-message -p '#S' 2>/dev/null || echo "")

# ── --preview SESSION (only runs when preview pane is visible) ────────
if [[ "${1:-}" == "--preview" ]]; then
  sess="${2:-}"
  [[ -z "$sess" ]] && exit 0
  meta=$(tmux display-message -t "$sess:" -p \
    '#{pane_current_path}|#{pane_current_command}|#{session_windows}' 2>/dev/null || echo "||")
  IFS='|' read -r path cmd wins <<<"$meta"
  panes=$(tmux list-panes -t "$sess" -s 2>/dev/null | wc -l | tr -d ' ')
  branch="—"
  [[ -e "${path:-}/.git" ]] && branch=$(git -C "$path" branch --show-current 2>/dev/null || echo "—")
  printf 'session   %s%s\nbranch    %s\npath      %s\ncommand   %s\nwindows   %s\npanes     %s\n\n── pane ──\n' \
    "$sess" "$([[ "$sess" == "$current" ]] && echo '  (current)')" \
    "${branch:-—}" "${path/#$HOME/~}" "$cmd" "$wins" "$panes"
  tmux capture-pane -ep -t "$sess:" 2>/dev/null | tail -n 40
  exit 0
fi

# ── --list  (one tmux call, no git) ───────────────────────────────────
if [[ "${1:-}" == "--list" ]]; then
  # Two fast tmux calls; merge pane counts with awk (no bash 4 assoc arrays)
  tmux list-sessions -F "#{session_name}|#{session_windows}|#{pane_current_command}|#{pane_current_path}" \
    > /tmp/tmux-sess-$$.txt
  tmux list-panes -a -F "#{session_name}" > /tmp/tmux-panes-$$.txt
  awk -v home="$HOME" -v cur="$current" '
    NR==FNR { panes[$0]++; next }
    {
      split($0, a, "|")
      sess=a[1]; wins=a[2]; cmd=a[3]; path=a[4]
      gsub("^" home, "~", path)
      mark = (sess == cur) ? "*" : " "
      pc = (sess in panes) ? panes[sess] : "?"
      n = ++idx
      num = (n <= 9) ? n : " "
      printf "%s\t%s %s %-22s │ %2sw %2sp  %-10s  %s\n", sess, num, mark, sess, wins, pc, cmd, path
    }
  ' /tmp/tmux-panes-$$.txt /tmp/tmux-sess-$$.txt
  rm -f /tmp/tmux-sess-$$.txt /tmp/tmux-panes-$$.txt
  exit 0
fi

# ── --panes SESSION ───────────────────────────────────────────────────
if [[ "${1:-}" == "--panes" ]]; then
  sess="${2:-}"
  [[ -z "$sess" ]] && exec "$SCRIPT"
  current_pane=$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null || echo "")
  pane_list=$(
    tmux list-panes -t "$sess" -s -F \
      '#{session_name}:#{window_index}.#{pane_index}\t#W\t#{pane_current_command}' \
      | awk -F'\t' '{
          n=++idx
          num=(n<=9)?n:" "
          printf "%s\t%s %-18s  %-12s  %s\n",$1,num,$1,$2,$3
        }'
  )
  start_pos=$(printf '%s\n' "$pane_list" | awk -F'\t' -v cur="$current_pane" '$1 == cur { print NR; exit }')
  [[ -z "${start_pos:-}" ]] && start_pos=1
  pick=$(
    printf '%s\n' "$pane_list" \
      | fzf --reverse \
          --delimiter=$'\t' --with-nth=2 \
          --prompt="$sess panes> " \
          --header="1-9=jump  │  enter=jump  │  ?=preview  │  esc=back" \
          --preview="tmux capture-pane -ep -t {1} 2>/dev/null | tail -n 40" \
          --preview-window=right:50%:wrap:hidden \
          --bind='?:toggle-preview' \
          --bind="load:pos(${start_pos})" \
          --bind='1:pos(1)+accept' \
          --bind='2:pos(2)+accept' \
          --bind='3:pos(3)+accept' \
          --bind='4:pos(4)+accept' \
          --bind='5:pos(5)+accept' \
          --bind='6:pos(6)+accept' \
          --bind='7:pos(7)+accept' \
          --bind='8:pos(8)+accept' \
          --bind='9:pos(9)+accept' \
      || true
  )
  [[ -z "${pick:-}" ]] && exec "$SCRIPT"
  tmux switch-client -t "${pick%%$'\t'*}"
  exit 0
fi

# ── main (preview hidden until ?) ─────────────────────────────────────
# Shortcuts first, then column labels (aligned with the list row).
HEADER="$(printf '%s\n%s\n%s' \
  '1-9=switch  │  enter=switch  │  ctrl-q=kill  │  ctrl-r=rename  │  ctrl-w=panes  │  ?=preview' \
  '────────────────────────────────────────────────────────────' \
  ' # SESSION               │ WINS PANES  CMD         PATH')"
session_list=$("$SCRIPT" --list)
start_pos=$(printf '%s\n' "$session_list" | awk -F'\t' -v cur="$current" '$1 == cur { print NR; exit }')
[[ -z "${start_pos:-}" ]] && start_pos=1
selected=$(
  printf '%s\n' "$session_list" \
    | fzf --reverse \
        --delimiter=$'\t' \
        --with-nth=2 \
        --prompt="session> " \
        --header="$HEADER" \
        --preview="$SCRIPT --preview {1}" \
        --preview-window=right:50%:wrap:hidden \
        --bind='?:toggle-preview' \
        --bind="load:pos(${start_pos})" \
        --bind='1:pos(1)+accept' \
        --bind='2:pos(2)+accept' \
        --bind='3:pos(3)+accept' \
        --bind='4:pos(4)+accept' \
        --bind='5:pos(5)+accept' \
        --bind='6:pos(6)+accept' \
        --bind='7:pos(7)+accept' \
        --bind='8:pos(8)+accept' \
        --bind='9:pos(9)+accept' \
        --bind="ctrl-q:execute-silent(tmux kill-session -t {1})+reload($SCRIPT --list)" \
        --bind="ctrl-r:execute(
            printf 'Rename \"%s\" to: ' {1} >/dev/tty
            read -r name </dev/tty
            [ -n \"\$name\" ] && tmux rename-session -t {1} \"\$name\"
          )+reload($SCRIPT --list)" \
        --bind="ctrl-w:become($SCRIPT --panes {1})" \
    || true
)

[[ -z "${selected:-}" ]] && exit 0
target="${selected%%$'\t'*}"
[[ -z "$target" || "$target" == "$current" ]] && exit 0
tmux switch-client -t "$target"
