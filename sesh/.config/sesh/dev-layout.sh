#!/usr/bin/env bash
# dev-layout.sh — 표준 3-window 개발 레이아웃(editor / agent / git)을 보장한다.
# sesh 의 startup_command 로 호출되며, 재접속 시 다시 실행돼도 안전(idempotent)하다.
#   - 윈도우가 이미 있으면 새로 만들지 않음
#   - editor 윈도우가 idle 셸일 때만 nvim 을 띄움(재접속 시 중복 실행 방지)
set -euo pipefail

session="$(tmux display-message -p '#S')"
path="$(tmux display-message -p '#{pane_current_path}')"

has_window() { tmux list-windows -t "$session" -F '#W' | grep -qx "$1"; }

# 1번 윈도우를 editor 로 정리
first="$(tmux list-windows -t "$session" -F '#I' | head -n1)"
tmux rename-window -t "$session:$first" editor

# agent / git 윈도우가 없으면 생성 (cwd 유지)
has_window agent || tmux new-window -t "$session" -c "$path" -n agent
has_window git || tmux new-window -t "$session" -c "$path" -n git

tmux select-window -t "$session:editor"

# editor 가 idle 셸이면 nvim 실행 (nvim 이 이미 떠 있으면 건너뜀)
pane_cmd="$(tmux display-message -p -t "$session:editor" '#{pane_current_command}')"
case "$pane_cmd" in
zsh | bash | fish | sh) tmux send-keys -t "$session:editor" 'nvim .' C-m ;;
esac
