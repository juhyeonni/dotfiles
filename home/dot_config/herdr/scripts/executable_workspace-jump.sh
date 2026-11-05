#!/usr/bin/env bash
# Project entry point (replaces sesh): focus the workspace for the picked path, create it if absent.
# One list: open workspaces (marked with their agent status) first, by recency, then
# recently opened, then zoxide and ghq.
# When the query matches nothing, the list offers `+ clone <query>` and `+ create <query>` instead.
#
# Duplicates are judged by path, not label (~/work/api and ~/oss/api share a basename).
# A workspace object has no cwd, so the path is stamped into the ws_root metadata token at
# creation time and looked up from there. A pane's cwd is only a fallback because cd moves it.
# Tokens live only in the running server, and workspaces created outside this picker have none.
# Those are matched by the cwd of their first pane (the one the workspace was created in), and
# the token is stamped then so later lookups use it again.
# No `set -e` here: failures are handled explicitly below instead.
set -uo pipefail

SELF="$(printf %q "$0")"
# Glyph per agent status, so color is never the only signal. ANSI colors follow the terminal's
# kanagawa palette. idle and done are both "ready for input" in herdr's docs, so they share one.
# The status legend sits on a footer line of its own, so the border label (keys and count) stays
# short enough for the list half of the popup.
STATUS_LEGEND=$'\e[32m●\e[0m ready  \e[33m◐\e[0m working  \e[31m◉\e[0m blocked  \e[2m○\e[0m none'
LEGEND='enter go   → agents   ^x close'
AGENT_LEGEND='enter go   ← back'
PREVIEW_WINDOW='right,45%,border-left'
CURRENT_MARK='  (current)'

# fzf callbacks. They run as `$0 --on-*` and talk to the picker through WSJ_STATE:
# `list` is the full list, `plus` exists while the clone/create rows are shown.
# The rows replace the list with search disabled, so any query shows them; the next keystroke
# restores the list and lets the search decide again.
# `agents` holds the workspace path while the list shows that workspace's agents instead.
on_result() {
  if [[ -e $WSJ_STATE/agents ]]; then
    echo "change-border-label: $AGENT_LEGEND   $FZF_MATCH_COUNT agents "
    return
  fi
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
  printf ' \t+ clone %s\tget\t%s\n \t+ create %s\tcreate\t%s\n' "$q" "$q" "$q" "$q"
}

# ctrl-x closes the open workspace under the cursor; rows not marked open do nothing.
# The workspace is found through ws_roots, the same lookup that marks the row as open.
# Only a working agent gets a prompt, which needs the terminal: execute, not execute-silent.
on_close() {
  local glyph p ws id
  IFS=$'\t' read -r glyph _ _ p <<<"$1"
  [[ -n ${glyph// /} ]] || return 0
  ws="$(ws_roots | awk -F'\t' -v p="$p" '$3 == p { print $1 "\t" $4; exit }')"
  [[ -n $ws ]] || return 0
  id="$(printf %q "${ws%%$'\t'*}")"
  if [[ ${ws#*$'\t'} == working ]]; then
    echo "execute($SELF --confirm-close $id)+reload($SELF --list)"
    return
  fi
  echo "execute-silent(herdr workspace close $id >/dev/null)+reload($SELF --list)"
}

# → on an open workspace swaps the list for its agents; ← brings the workspaces back.
# Anywhere else the arrows keep moving the query cursor.
on_right() {
  local glyph label p
  IFS=$'\t' read -r glyph label _ p <<<"$1"
  if [[ -e $WSJ_STATE/agents || -z ${glyph// /} ]]; then
    echo forward-char
    return
  fi
  printf '%s\n' "$p" >"$WSJ_STATE/agents"
  read -r label _ <<<"$label"
  echo "change-prompt($label > )+clear-query+change-preview-window(hidden)+reload:$SELF --agents $(printf %q "$p")"
}

on_left() {
  if [[ ! -e $WSJ_STATE/agents ]]; then
    echo backward-char
    return
  fi
  rm -f "$WSJ_STATE/agents"
  echo "change-prompt(workspace > )+clear-query+change-preview-window($PREVIEW_WINDOW)+reload:cat $(printf %q "$WSJ_STATE/list")"
}

confirm_close() {
  local key
  printf 'The agent in this workspace is working. Close it anyway? [y/N] '
  read -rsn1 key
  [[ $key == y ]] || return 0
  herdr workspace close "$1" >/dev/null
}

case "${1:-}" in
--on-result) on_result; exit ;;
--on-change) on_change; exit ;;
--on-right) on_right "$2"; exit ;;
--on-left) on_left; exit ;;
--confirm-close) confirm_close "$2"; exit ;;
--plus) plus_rows; exit ;;
# The preview runs on every cursor move, so it reads the cache before any of the setup below.
--preview)
  [[ $2 == open ]] || exit 0
  awk -F'\t' -v p="$3" '$1 == p { print $2 " " $3; n++ }
    END { if (!n) print "\033[2mnot open\033[0m" }' "$WSJ_STATE/agents.tsv"
  exit
  ;;
--agents)
  awk -F'\t' -v p="$2" '$1 == p && $4 != "-" { print $2 "\t" $3 "\tagent\t" $4 }' "$WSJ_STATE/agents.tsv"
  exit
  ;;
esac

for cmd in zoxide fzf jq ghq herdr; do
  command -v "$cmd" >/dev/null || { echo "required command not found: $cmd" >&2; exit 1; }
done

GHQ_ROOT="$(ghq root)"
# zoxide exposes no last-access time, and its score is rank (cumulative hits) x a recency multiplier,
# which cancels out within a session and degrades to frequency order. Track "recently opened" here.
MRU_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/herdr/workspace-mru"
MRU_MAX=50

# The popup closes the instant the command exits — give the user time to read the error.
fail() {
  printf '\n%s\n\nPress any key to continue...' "$1" >&2
  read -rsn1
}


# Sets g instead of printing it: a $(glyph) subshell per row costs a fork, and the list has
# hundreds of rows.
set_glyph() {
  case "$1" in
  ' ') g=' ' ;;
  blocked) g=$'\e[31m◉\e[0m' ;;
  working) g=$'\e[33m◐\e[0m' ;;
  idle | done) g=$'\e[32m●\e[0m' ;;
  *) g=$'\e[2m○\e[0m' ;;
  esac
}

# Writes WSJ_STATE/agents.tsv, "<root>\t<glyph>\t<tab>  <dim title>\t<pane_id>" per agent, so the
# preview and the → list only read a file instead of querying herdr on every cursor move.
# An open workspace without agents gets one "no agents" row with pane "-". The title is the task
# Claude Code writes into its terminal title. Runs after ws_roots has stamped ws_root everywhere.
# ponytail: a snapshot taken when the list is built; it goes stale while the popup stays open.
write_agent_cache() {
  local rows root status tab title pane g
  rows="$(jq -rn --argjson w "$(herdr workspace list)" --argjson a "$(herdr agent list)" '
    $w.result.workspaces[]? | select(.tokens.ws_root) | .tokens.ws_root as $r | .workspace_id as $id
    | [$a.result.agents[]? | select(.workspace_id == $id)] as $ag
    | if $ag == [] then [$r, "-", "-", "-", "-"] else
        $ag[] | [$r, .agent_status // "unknown", (.tab_id | split(":")[1]),
                 (.terminal_title_stripped // .agent // "-"), .pane_id]
      end
    | @tsv')" || return 0
  while IFS=$'\t' read -r root status tab title pane; do
    [[ -n $root ]] || continue
    if [[ $pane == - ]]; then
      printf '%s\t \t\e[2mno agents\e[0m\t-\n' "$root"
      continue
    fi
    set_glyph "$status"
    printf '%s\t%s\t%s  \e[2m%s\e[0m\t%s\n' "$root" "$g" "$tab" "$title" "$pane"
  done <<<"$rows" >"$WSJ_STATE/agents.tsv"
}

# "<glyph>\t<label> <dim path>\t<kind>\t<absolute path>". The glyph has a field of its own so the
# search (--nth=2) never matches it. ghq entries shrink to owner/repo —
# ~/.ghq/github.com/ is noise repeated on every row; the path stays searchable.
render() {
  local status="$1" p="$2" mark="${3:-}" shown g
  set_glyph "$status"
  case "$p" in
  "$GHQ_ROOT"/*) shown="${p#"$GHQ_ROOT"/}"; shown="${shown#*/}" ;;
  "$HOME") shown='~' ;;
  "$HOME"/*) shown="~${p#"$HOME"}" ;;
  *) shown="$p" ;;
  esac
  printf '%s\t%-20s \e[2m%s%s\e[0m\topen\t%s\n' "$g" "${p##*/}" "$shown" "$mark" "$p"
}

# "<workspace_id>\t<focused>\t<root>\t<agent_status>" for every open workspace whose root is known.
ws_roots() {
  local rows id focused by root status
  # Every field is non-empty: read collapses adjacent tabs, which would shift an empty one away.
  rows="$(jq -rn --argjson w "$(herdr workspace list)" --argjson p "$(herdr pane list)" '
    (reduce ($p.result.panes[]?) as $x ({}; .[$x.workspace_id] //= $x.cwd)) as $cwd
    | $w.result.workspaces[]?
    | (.agent_status // "unknown") as $st
    | if .tokens.ws_root then [.workspace_id, .focused, "token", .tokens.ws_root, $st]
      elif $cwd[.workspace_id] then [.workspace_id, .focused, "cwd", $cwd[.workspace_id], $st]
      else empty end
    | @tsv')" || return 0
  while IFS=$'\t' read -r id focused by root status; do
    [[ -n $root ]] || continue
    if [[ $by == cwd ]]; then
      root="$(cd "$root" 2>/dev/null && pwd -P)" || continue
      herdr workspace report-metadata "$id" \
        --source workspace-jump --token "ws_root=$root" >/dev/null || true
    fi
    printf '%s\t%s\t%s\t%s\n' "$id" "$focused" "$root" "$status"
  done <<<"$rows"
}

# The current workspace leads the list, marked, so its agents show in the preview too. The picker
# starts the cursor on the row below it, "the last place you were", which behaves like alt-tab.
build_list() {
  local ws cur open
  ws="$(ws_roots)"
  write_agent_cache
  cur="$(awk -F'\t' '$2 == "true" { print $3 }' <<<"$ws")"
  open="$(awk -F'\t' '$2 == "false" { print $4 "\t" $3 }' <<<"$ws")"
  {
    awk -F'\t' '$2 == "true" { print $4 "\t" $3 }' <<<"$ws"
    # Open workspaces in MRU order; open ones never opened through here follow in sidebar order.
    [[ -n $open ]] && {
      [[ -f $MRU_FILE ]] && awk -F'\t' 'NR == FNR { st[$2] = $1; next } $0 in st { print st[$0] "\t" $0 }' \
        <(printf '%s\n' "$open") "$MRU_FILE"
      printf '%s\n' "$open"
    }
    { [[ -f $MRU_FILE ]] && cat "$MRU_FILE"; zoxide query -l; ghq list -p; } | sed 's/^/ \t/'
  } | awk -F'\t' '$2 != "" && !seen[$2]++' |
    while IFS=$'\t' read -r status p; do
      [[ -d $p ]] || continue
      if [[ $p == "$cur" ]]; then
        render "$status" "$p" "$CURRENT_MARK"
      else
        render "$status" "$p"
      fi
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

# The zoxide hook only sees cd. Opening a workspace is not a cd, so bump the score manually
# to keep frecency ranking "recently opened workspaces". Only call this once the workspace is open,
# so a path that failed to open does not climb the list.
mark_opened() {
  zoxide add "$1"
  mru_add "$1"
}

open_workspace() {
  local sel="$1" target existing id label
  [[ -d $sel ]] || { fail "no such path: $sel"; return 1; }
  # On macOS /tmp is a link to /private/tmp, so normalize to the resolved absolute path.
  target="$(cd "$sel" && pwd -P)"

  existing="$(ws_roots | awk -F'\t' -v p="$target" '$3 == p { print $1; exit }')"

  if [[ -n $existing ]]; then
    herdr workspace focus "$existing" >/dev/null
    mark_opened "$target"
    return 0
  fi

  # ghq repos are labelled owner/repo, like the dim path in render(), so same-named repos stay
  # apart in the sidebar. Other paths have no owner, so they keep the basename.
  label="${target##*/}"
  [[ $target == "$GHQ_ROOT"/*/*/* ]] && { label="${target#"$GHQ_ROOT"/}"; label="${label#*/}"; }

  id="$(herdr workspace create --cwd "$target" --label "$label" --focus |
    jq -r '.result.workspace.workspace_id')"
  if [[ -z $id || $id == null ]]; then
    fail "workspace create failed: $target"
    return 1
  fi
  mark_opened "$target"
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

# Callbacks that need ws_roots or build_list, so they run once those are defined.
# --list is the reload after ctrl-x. It rewrites the saved list too, so leaving the clone/create
# rows does not bring back the closed workspace.
case "${1:-}" in
--on-close) on_close "$2"; exit ;;
--list) build_list | tee "$WSJ_STATE/list"; exit ;;
esac

export WSJ_STATE
WSJ_STATE="$(mktemp -d)" || exit 1
trap 'rm -rf "$WSJ_STATE"' EXIT

while true; do
  rm -f "$WSJ_STATE/plus" "$WSJ_STATE/agents"
  build_list >"$WSJ_STATE/list"
  first=''
  IFS= read -r first <"$WSJ_STATE/list"
  start='start:pos(1)'
  [[ $first == *"$CURRENT_MARK"* ]] && start='start:pos(2)'

  sel="$(fzf <"$WSJ_STATE/list" \
    --bind "$start" \
    --delimiter='\t' --with-nth=1,2 --nth=2 --tabstop=2 --ansi \
    --tiebreak=index \
    --layout=reverse --info=hidden --prompt='workspace > ' \
    --border=bottom --border-label-pos=2:bottom --border-label=" $LEGEND " \
    --footer=" $STATUS_LEGEND" \
    --height=100% \
    --preview "$SELF --preview {3} {4}" --preview-window="$PREVIEW_WINDOW" \
    --bind "right:transform:$SELF --on-right {}" \
    --bind "left:transform:$SELF --on-left" \
    --bind "result:transform:$SELF --on-result" \
    --bind "change:transform:$SELF --on-change" \
    --bind "ctrl-x:transform:$SELF --on-close {}")"

  [[ -n $sel ]] || exit 0 # ESC
  IFS=$'\t' read -r _ _ kind arg <<<"$sel"
  case "$kind" in
  open) open_workspace "$arg" && break ;;
  agent)
    herdr agent focus "$arg" >/dev/null && mark_opened "$(<"$WSJ_STATE/agents")" && break
    fail "agent focus failed: $arg"
    ;;
  *) ghq_run_and_open "$kind" "$arg" && break ;;
  esac
done
