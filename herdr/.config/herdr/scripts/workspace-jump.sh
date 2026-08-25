#!/usr/bin/env bash
# 프로젝트 진입점 (sesh 대체): 고른 경로의 workspace 가 있으면 focus, 없으면 create.
# ctrl-g/ctrl-n 으로 ghq clone/create 까지 한다.
#
# 중복 판정은 라벨이 아니라 경로로 한다(~/work/api 와 ~/oss/api 는 basename 이 같다).
# workspace 객체에 cwd 가 없어서 생성 시 metadata 토큰 ws_root 에 새겨두고 그걸로 찾는다.
# pane 의 cwd 를 안 쓰는 이유는 셸에서 cd 하면 값이 흔들리기 때문.
# 한계: picker 밖에서 만든 workspace 에는 이 토큰이 없어 같은 경로가 중복될 수 있다.
# set -e 는 쓰지 않는다. `git_repos | head` 에서 head 가 파이프를 닫으면 SIGPIPE(141)로
# 스크립트가 죽는다. 실패는 아래에서 명시적으로 처리한다.
set -uo pipefail

for cmd in zoxide fzf jq ghq herdr; do
  command -v "$cmd" >/dev/null || { echo "필요한 명령이 없습니다: $cmd" >&2; exit 1; }
done

GHQ_ROOT="$(ghq root)"
TOP=8

# 팝업은 명령이 끝나면 즉시 닫힌다 — 에러를 읽을 시간을 준다.
fail() {
  printf '\n%s\n\n계속하려면 아무 키나 누르세요...' "$1" >&2
  read -rsn1
}

# "<표시>\t<절대경로>". ghq 는 owner/repo 로 줄인다 — ~/.ghq/github.com/ 은 모든
# 항목에 똑같이 붙는 잡음이라 지우면 한 줄이 짧아지고 구분도 형태로 드러난다.
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

open_workspace() {
  local sel="$1" target existing id
  [[ -d $sel ]] || { fail "경로가 없습니다: $sel"; return 1; }
  # macOS 는 /tmp → /private/tmp 라 링크를 푼 절대경로로 맞춘다.
  target="$(cd "$sel" && pwd -P)"

  # zoxide 훅은 cd 만 잡는다. workspace 를 여는 건 cd 가 아니므로 직접 올려야
  # frecency 가 "최근 연 workspace" 랭킹이 된다.
  zoxide add "$target"

  existing="$(herdr workspace list |
    jq -r --arg p "$target" '.result.workspaces[]? | select(.tokens.ws_root == $p) | .workspace_id' |
    head -n1)"

  if [[ -n $existing ]]; then
    herdr workspace focus "$existing" >/dev/null
    return 0
  fi

  id="$(herdr workspace create --cwd "$target" --label "${target##*/}" --focus |
    jq -r '.result.workspace.workspace_id')"
  # 실패해도 진입은 이미 끝났다. 다음에 같은 경로를 고르면 중복 생성될 뿐.
  herdr workspace report-metadata "$id" \
    --source workspace-jump --token "ws_root=$target" >/dev/null || true
}

# ghq get/create 후 어디에 생겼는지 찾는다. 쿼리가 URL 형태여도 안전하도록
# before/after 차집합을 쓰고, 이미 있던 경우(get 이 아무 일도 안 함)만 -e 로 떨어진다.
ghq_run_and_open() {
  local action="$1" query="$2" before new
  before="$(ghq list -p | sort)"
  if ! ghq "$action" "$query"; then
    fail "ghq $action 실패: $query"
    return 1
  fi
  new="$(comm -13 <(printf '%s\n' "$before") <(ghq list -p | sort) | head -n1)"
  [[ -n $new ]] || new="$(ghq list -p -e "$query" | head -n1)"
  [[ -n $new ]] || { fail "받았지만 경로를 찾지 못했습니다: $query"; return 1; }
  open_workspace "$new"
}

mode=default
while true; do
  case "$mode" in
  ghq) src="$(ghq list -p | render)"; hdr='[ghq] enter 열기 · ctrl-t 전체' ;;
  all) src="$(git_repos | render)"; hdr='[전체] enter 열기 · ctrl-r ghq' ;;
  *) src="$(git_repos | head -n "$TOP" | render)"
     hdr='enter 열기 · ctrl-g clone · ctrl-n 새 리포 · ctrl-r ghq · ctrl-t 전체' ;;
  esac

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
