#!/usr/bin/env bash
# tmux 의 join-pane: 지금 pane 을 고른 탭으로 옮긴다 (prefix+shift+v = break 의 역동작).
# 같은 workspace 의 탭만 보여준다 — 다른 space 로 보내는 건 `herdr pane move --workspace`.
#
# 대상은 UI 가 focus 한 pane 이다. popup 이 pane 트리에 안 들어간다는 가정에 기대므로,
# 잡힌 pane id 를 fzf 프롬프트에 찍어둔다. 엉뚱한 게 잡히면 ESC 로 빠져나오면 된다.
set -uo pipefail

for cmd in fzf jq herdr; do
  command -v "$cmd" >/dev/null || { echo "필요한 명령이 없습니다: $cmd" >&2; exit 1; }
done

# 팝업은 명령이 끝나면 즉시 닫힌다 — 에러를 읽을 시간을 준다.
fail() {
  printf '\n%s\n\n계속하려면 아무 키나 누르세요...' "$1" >&2
  read -rsn1
}

cur="$(herdr pane current)" || { fail "herdr 에 연결하지 못했습니다."; exit 1; }
read -r pane tab ws < <(jq -r '.result.pane | "\(.pane_id) \(.tab_id) \(.workspace_id)"' <<<"$cur")

# "<표시>\t<tab_id>". 지금 탭은 뺀다. 이름을 안 준 탭은 라벨이 번호와 같아 번호만 남긴다.
list="$(herdr tab list --workspace "$ws" | jq -r --arg tab "$tab" '
  .result.tabs[]? | select(.tab_id != $tab)
  | " \(.number)\(if .label == "\(.number)" then "" else " " + .label end)\t\(.tab_id)"')"

[[ -n $list ]] || { fail "옮길 탭이 없습니다."; exit 0; }

sel="$(fzf --delimiter='\t' --with-nth=1 --nth=1 \
  --header='enter join' --prompt="$pane → " \
  --no-border --ansi --height=100% <<<"$list" | cut -f2)"

[[ -n $sel ]] || exit 0 # ESC
# --tab 형식은 --split 이 필수다(--new-tab 과 달리). 세로 분할이 기본값.
herdr pane move "$pane" --tab "$sel" --split right --focus >/dev/null ||
  fail "옮기지 못했습니다: $pane → $sel"
