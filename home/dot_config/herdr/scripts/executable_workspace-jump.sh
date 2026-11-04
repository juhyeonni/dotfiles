#!/usr/bin/env bash
# Project entry point (replaces sesh): focus the workspace for the picked path, create it if absent.
# One list, no modes: open workspaces (●) first, then recently opened, then zoxide and ghq.
# When the query matches nothing, the list offers `+ clone <query>` and `+ create <query>` instead.
#
# Duplicates are judged by path, not label (~/work/api and ~/oss/api share a basename).
# A workspace object has no cwd, so the path is stamped into the ws_root metadata token at
# creation time and looked up from there. A pane's cwd is not used because cd in the shell moves it.
# Limitation: workspaces created outside this picker carry no token, so a path can be duplicated
# and they are not marked as open.
# No `set -e` here: failures are handled explicitly below instead.
set -uo pipefail

SELF="$(printf %q "$0")"
LEGEND='● open   enter go'

# fzf callbacks. They run as `$0 --on-*` and talk to the picker through WSJ_STATE:
# `list` is the full list, `plus` exists while the clone/create rows are shown.
# The rows replace the list with search disabled, so any query shows them; the next keystroke
# restores the list and lets the search decide again.
on_result() {
  if [[ -e $WSJ_STATE/plus ]]; then
    echo "change-border-label: $LEGEND   0 projects "
    return
  fi
  if ((FZF_MATCH_COUNT == 0)) && [[ -n $FZF_QUERY ]]; then
    touch "$WSJ_STATE/plus"
    echo "disable-search+reload:$SELF --plus"
    return
  fi
  echo "change-border-label: $LEGEND   $FZF_MATCH_COUNT projects "
}

on_change() {
  [[ -e $WSJ_STATE/plus ]] || return 0
  rm -f "$WSJ_STATE/plus"
  echo "enable-search+reload:cat $(printf %q "$WSJ_STATE/list")"
}

plus_rows() {
  local q
  read -r q <<<"$FZF_QUERY"
  printf '+ clone %s\tget\t%s\n+ create %s\tcreate\t%s\n' "$q" "$q" "$q" "$q"
}

case "${1:-}" in
--on-result) on_result; exit ;;
--on-change) on_change; exit ;;
--plus) plus_rows; exit ;;
esac

for cmd in zoxide fzf jq ghq herdr; do
  command -v "$cmd" >/dev/null || { echo "required command not found: $cmd" >&2; exit 1; }
done

GHQ_ROOT="$(ghq root)"
# zoxide exposes no last-access time, and its score is rank (cumulative hits) x a recency multiplier,
# which cancels out within a session and degrades to frequency order. Track "recently opened" here.
MRU_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/herdr/workspace-mru"
MRU_MAX=50

export WSJ_STATE
WSJ_STATE="$(mktemp -d)" || exit 1
trap 'rm -rf "$WSJ_STATE"' EXIT

# The popup closes the instant the command exits — give the user time to read the error.
fail() {
  printf '\n%s\n\nPress any key to continue...' "$1" >&2
  read -rsn1
}

# "<marker> <label> <dim path>\t<kind>\t<absolute path>". ghq entries shrink to owner/repo —
# ~/.ghq/github.com/ is noise repeated on every row; the path stays searchable.
render() {
  local mark="$1" p="$2" shown
  case "$p" in
  "$GHQ_ROOT"/*) shown="${p#"$GHQ_ROOT"/}"; shown="${shown#*/}" ;;
  "$HOME") shown='~' ;;
  "$HOME"/*) shown="~${p#"$HOME"}" ;;
  *) shown="$p" ;;
  esac
  printf '%s %-20s \e[2m%s\e[0m\topen\t%s\n' "$mark" "${p##*/}" "$shown" "$p"
}

# The current workspace is dropped — no point jumping to where you already are, and dropping it
# makes the top entry "the last place you were", which behaves like alt-tab.
build_list() {
  local ws cur open
  ws="$(herdr workspace list |
    jq -r '.result.workspaces[]? | select(.tokens.ws_root) | "\(.focused)\t\(.tokens.ws_root)"')"
  cur="$(awk -F'\t' '$1 == "true" { print $2 }' <<<"$ws")"
  open="$(awk -F'\t' '$1 == "false" { print $2 }' <<<"$ws")"
  {
    [[ -n $open ]] && sed 's/^/●\t/' <<<"$open"
    { [[ -f $MRU_FILE ]] && cat "$MRU_FILE"; zoxide query -l; ghq list -p; } | sed 's/^/ \t/'
  } | awk -F'\t' -v cur="$cur" '$2 != "" && $2 != cur && !seen[$2]++' |
    while IFS=$'\t' read -r mark p; do
      [[ -d $p ]] && render "$mark" "$p"
    done
}

mru_add() {
  local tmp
  mkdir -p "${MRU_FILE%/*}"
  tmp="$(mktemp)" || return 0
  # pipefail caveat: the group must exit 0 for the mv to run. A false [[ -f ]], or grep returning
  # 0 lines (everything filtered out by -v), must not be counted as failure.
  {
    printf '%s\n' "$1"
    [[ -f $MRU_FILE ]] && { grep -vxF "$1" "$MRU_FILE" || true; }
    :
  } | head -n "$MRU_MAX" >"$tmp" && mv "$tmp" "$MRU_FILE"
}

open_workspace() {
  local sel="$1" target existing id
  [[ -d $sel ]] || { fail "no such path: $sel"; return 1; }
  # On macOS /tmp is a link to /private/tmp, so normalize to the resolved absolute path.
  target="$(cd "$sel" && pwd -P)"

  # The zoxide hook only sees cd. Opening a workspace is not a cd, so bump the score manually
  # to keep frecency ranking "recently opened workspaces".
  zoxide add "$target"
  mru_add "$target"

  existing="$(herdr workspace list |
    jq -r --arg p "$target" '.result.workspaces[]? | select(.tokens.ws_root == $p) | .workspace_id' |
    head -n1)"

  if [[ -n $existing ]]; then
    herdr workspace focus "$existing" >/dev/null
    return 0
  fi

  id="$(herdr workspace create --cwd "$target" --label "${target##*/}" --focus |
    jq -r '.result.workspace.workspace_id')"
  # A failure here is harmless — entry already happened. Picking the same path again just duplicates.
  herdr workspace report-metadata "$id" \
    --source workspace-jump --token "ws_root=$target" >/dev/null || true
}

# Find where ghq get/create put things. A before/after set difference keeps URL-shaped queries safe;
# only the already-present case (get did nothing) falls through to the -e lookup.
ghq_run_and_open() {
  local action="$1" query="$2" before new
  before="$(ghq list -p | sort)"
  if ! ghq "$action" "$query"; then
    fail "ghq $action failed: $query"
    return 1
  fi
  new="$(comm -13 <(printf '%s\n' "$before") <(ghq list -p | sort) | head -n1)"
  [[ -n $new ]] || new="$(ghq list -p -e "$query" | head -n1)"
  [[ -n $new ]] || { fail "fetched, but could not locate the path: $query"; return 1; }
  open_workspace "$new"
}

while true; do
  rm -f "$WSJ_STATE/plus"
  build_list >"$WSJ_STATE/list"

  sel="$(fzf <"$WSJ_STATE/list" \
    --delimiter='\t' --with-nth=1 --nth=1 --ansi \
    --layout=reverse --info=hidden --prompt='workspace > ' \
    --border=bottom --border-label-pos=2:bottom --border-label=" $LEGEND " \
    --height=100% \
    --bind "result:transform:$SELF --on-result" \
    --bind "change:transform:$SELF --on-change")"

  [[ -n $sel ]] || exit 0 # ESC
  IFS=$'\t' read -r _ kind arg <<<"$sel"
  case "$kind" in
  open) open_workspace "$arg" && break ;;
  *) ghq_run_and_open "$kind" "$arg" && break ;;
  esac
done
