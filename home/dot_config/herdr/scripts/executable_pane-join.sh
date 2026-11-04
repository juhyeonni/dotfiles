#!/usr/bin/env bash
# tmux's join-pane: move the current pane into a picked tab (the inverse of prefix+shift+v = break).
# Only tabs in the same workspace are listed — sending to another space is `herdr pane move --workspace`.
#
# The target is whichever pane the UI has focused. That leans on the assumption that a popup does not
# enter the pane tree, so the resolved pane id is printed in the fzf prompt. If it grabbed the wrong
# one, ESC out.
set -uo pipefail

for cmd in fzf jq herdr; do
  command -v "$cmd" >/dev/null || { echo "required command not found: $cmd" >&2; exit 1; }
done

# The popup closes the instant the command exits — give the user time to read the error.
fail() {
  printf '\n%s\n\nPress any key to continue...' "$1" >&2
  read -rsn1
}

cur="$(herdr pane current)" || { fail "could not connect to herdr."; exit 1; }
read -r pane tab ws < <(jq -r '.result.pane | "\(.pane_id) \(.tab_id) \(.workspace_id)"' <<<"$cur")

# "<label>\t<tab_id>". The current tab is excluded. An unnamed tab's label equals its number, so
# only the number is kept.
list="$(herdr tab list --workspace "$ws" | jq -r --arg tab "$tab" '
  .result.tabs[]? | select(.tab_id != $tab)
  | " \(.number)\(if .label == "\(.number)" then "" else " " + .label end)\t\(.tab_id)"')"

[[ -n $list ]] || { fail "no tab to move into."; exit 0; }

sel="$(fzf --delimiter='\t' --with-nth=1 --nth=1 \
  --header='enter join' --prompt="$pane → " \
  --no-border --ansi --height=100% <<<"$list" | cut -f2)"

[[ -n $sel ]] || exit 0 # ESC
# The --tab form requires --split (unlike --new-tab). A vertical split is the default.
herdr pane move "$pane" --tab "$sel" --split right --focus >/dev/null ||
  fail "move failed: $pane → $sel"
