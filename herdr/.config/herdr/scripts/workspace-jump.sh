#!/usr/bin/env bash
# Project entry point (replaces sesh): focus the workspace for the picked path, create it if absent.
# ctrl-g / ctrl-n also run ghq clone/create.
#
# Duplicates are judged by path, not label (~/work/api and ~/oss/api share a basename).
# A workspace object has no cwd, so the path is stamped into the ws_root metadata token at
# creation time and looked up from there. A pane's cwd is not used because cd in the shell moves it.
# Limitation: workspaces created outside this picker carry no token, so a path can be duplicated.
# No `set -e` here. In `git_repos | head`, head closing the pipe kills the script with SIGPIPE (141).
# Failures are handled explicitly below instead.
set -uo pipefail

for cmd in zoxide fzf jq ghq herdr; do
  command -v "$cmd" >/dev/null || { echo "required command not found: $cmd" >&2; exit 1; }
done

GHQ_ROOT="$(ghq root)"
TOP=8
# zoxide exposes no last-access time, and its score is rank (cumulative hits) x a recency multiplier,
# which cancels out within a session and degrades to frequency order. Track "recently opened" here.
MRU_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/herdr/workspace-mru"
MRU_MAX=50

# The popup closes the instant the command exits — give the user time to read the error.
fail() {
  printf '\n%s\n\nPress any key to continue...' "$1" >&2
  read -rsn1
}

# "<label>\t<absolute path>". ghq entries shrink to owner/repo — ~/.ghq/github.com/ is noise
# repeated on every row; dropping it shortens the line and lets the shape do the distinguishing.
render() {
  while IFS= read -r p; do
    [[ -n $p ]] || continue
    case "$p" in
    "$GHQ_ROOT"/*)
      rel="${p#"$GHQ_ROOT"/}"
      printf ' %s\t%s\n' "${rel#*/}" "$p"
      ;;
    "$HOME"/*) printf ' ~%s\t%s\n' "${p#"$HOME"}" "$p" ;;
    *) printf ' %s\t%s\n' "$p" "$p" ;;
    esac
  done
}

git_repos() {
  zoxide query -l | while IFS= read -r d; do [[ -d $d/.git ]] && printf '%s\n' "$d"; done
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

# The current workspace is dropped from the default list — no point jumping to where you already
# are, and dropping it makes the top entry "the last place you were", which behaves like alt-tab.
current_ws_root() {
  herdr workspace list |
    jq -r '.result.workspaces[]? | select(.focused == true) | .tokens.ws_root // empty' | head -n1
}

# MRU first, then zoxide order to fill the rest (on a new machine the MRU is empty).
list_recent() {
  local cur; cur="$(current_ws_root)"
  { [[ -f $MRU_FILE ]] && cat "$MRU_FILE"; git_repos; } |
    awk 'NF && !seen[$0]++' |
    while IFS= read -r d; do
      [[ -d $d/.git && $d != "$cur" ]] && printf '%s\n' "$d"
    done | head -n "$TOP"
}

# ghq entries ordered by zoxide rank. Repos zoxide has never seen are pushed to the back.
list_ghq() {
  awk 'NR == FNR { idx[$0] = FNR; next }
       { printf "%d\t%s\n", ($0 in idx ? idx[$0] : 999999999), $0 }' \
    <(zoxide query -l) <(ghq list -p) | sort -n -k1,1 | cut -f2
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

mode=default
while true; do
  # Two fixed rows. Row 1 is the list you are looking at and the keys that change it; row 2 is the
  # keys that act on **the typed string**, not on the list — splitting the header makes that visible.
  hdr2='typed name → ctrl-g clone · ctrl-n create'
  case "$mode" in
  ghq) src="$(list_ghq | render)"; hdr1='[ghq] enter open · ctrl-t all' ;;
  all) src="$(git_repos | render)"; hdr1='[all] enter open · ctrl-r ghq' ;;
  *) src="$(list_recent | render)"
     hdr1='[recent] enter open · ctrl-r ghq · ctrl-t all' ;;
  esac
  hdr="$hdr1"$'\n'"$hdr2"

  out="$(printf '%s\n' "$src" | fzf \
    --print-query --expect=ctrl-g,ctrl-n,ctrl-r,ctrl-t \
    --delimiter='\t' --with-nth=1 --nth=1 \
    --header="$hdr" --prompt='workspace > ' \
    --no-border --ansi --height=100%)"

  query="$(sed -n 1p <<<"$out")"
  key="$(sed -n 2p <<<"$out")"
  sel="$(sed -n 3p <<<"$out" | cut -f2)"

  case "$key" in
  ctrl-r) mode=ghq; continue ;;
  ctrl-t) mode=all; continue ;;
  ctrl-g) [[ -n $query ]] || continue; ghq_run_and_open get "$query" && break; continue ;;
  ctrl-n) [[ -n $query ]] || continue; ghq_run_and_open create "$query" && break; continue ;;
  esac

  [[ -n $sel ]] || exit 0   # ESC
  open_workspace "$sel"
  break
done
