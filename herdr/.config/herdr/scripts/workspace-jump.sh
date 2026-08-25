#!/usr/bin/env bash
# workspace-jump.sh — 프로젝트 진입점. tmux 시절 `prefix + S` (sesh) 를 대체한다.
#
# sesh 의 핵심 동작은 "세션이 있으면 attach, 없으면 생성"이었다. herdr 에는 그런
# 원자적 동작이 없어서 조립한다: 목록 → 선택 → 있으면 focus, 없으면 create.
#
# 중복 판정은 라벨이 아니라 **경로**로 한다 (~/work/api 와 ~/oss/api 는 basename 이
# 같다). workspace 객체에는 cwd 필드가 없으므로, 생성 시 원본 경로를 metadata
# 토큰 ws_root 에 찍어두고 그걸로 조회한다. pane 의 cwd 를 쓰지 않는 이유는
# 사용자가 셸에서 cd 하면 값이 흔들리기 때문이다.
#
# 후보 목록은 zoxide 가 준다. .zshrc 의 ghq→zoxide 브리지가 clone 직후의 리포까지
# 밀어 넣으므로, 방문 이력이 없는 리포도 즉시 여기 뜬다.
set -euo pipefail

for cmd in zoxide fzf jq herdr; do
  command -v "$cmd" >/dev/null || { echo "필요한 명령이 없습니다: $cmd" >&2; exit 1; }
done

# 사라진 디렉토리는 zoxide 에 남아 있어도 후보에서 뺀다.
selection="$(zoxide query -l | while IFS= read -r d; do [[ -d $d ]] && printf '%s\n' "$d"; done \
  | fzf --no-border --ansi --prompt='workspace > ' --height=100%)" || exit 0
[[ -n $selection ]] || exit 0

# 심볼릭 링크를 푼 절대경로로 정규화한다 (macOS 는 /tmp → /private/tmp 처럼 다르다).
target="$(cd "$selection" && pwd -P)"

existing="$(herdr workspace list \
  | jq -r --arg p "$target" '.result.workspaces[]? | select(.tokens.ws_root == $p) | .workspace_id' \
  | head -n1)"

if [[ -n $existing ]]; then
  herdr workspace focus "$existing" >/dev/null
  exit 0
fi

workspace_id="$(herdr workspace create --cwd "$target" --label "${target##*/}" --focus \
  | jq -r '.result.workspace.workspace_id')"

# 다음번 조회를 위해 원본 경로를 새긴다. 실패해도 workspace 자체는 이미 살아 있으므로
# 진입을 막지 않는다 — 다음에 같은 경로를 고르면 중복 생성될 뿐이다.
herdr workspace report-metadata "$workspace_id" \
  --source workspace-jump --token "ws_root=$target" >/dev/null || true
