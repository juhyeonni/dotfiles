#!/usr/bin/env bash
# 스피너 데몬: busy 윈도우가 하나라도 있는 동안 @claude-spinner 옵션을
# ~150ms 간격으로 갱신하고 클라이언트 상태바를 강제 리프레시한다.
# busy 윈도우가 없어지면 스스로 종료. notify.sh(busy)가 기동한다.

FRAMES=(· ✢ ✳ ✻ ✽ ✻ ✳ ✢)
INTERVAL=0.15

# singleton: 이미 떠 있으면 종료
existing=$(tmux show-option -gqv @claude-spinner-pid 2>/dev/null)
if [ -n "$existing" ] && kill -0 "$existing" 2>/dev/null; then
  exit 0
fi
tmux set-option -gq @claude-spinner-pid $$ 2>/dev/null
# 동시 기동 레이스 방지: 내 pid가 아니면 다른 데몬이 이김
[ "$(tmux show-option -gqv @claude-spinner-pid 2>/dev/null)" = "$$" ] || exit 0

refresh_clients() {
  local c
  for c in $(tmux list-clients -F '#{client_name}' 2>/dev/null); do
    tmux refresh-client -S -t "$c" 2>/dev/null
  done
}

i=0
while :; do
  # tmux 서버가 죽었거나 busy 윈도우가 없으면 종료 (@claude-busy는 카운트)
  busy=$(tmux list-windows -aF '#{@claude-busy}' 2>/dev/null) || break
  echo "$busy" | awk '$1 > 0 { found = 1 } END { exit !found }' || break

  tmux set-option -gq @claude-spinner "${FRAMES[$((i % ${#FRAMES[@]}))]}" 2>/dev/null
  refresh_clients
  i=$((i + 1))
  sleep "$INTERVAL"
done

tmux set-option -gu @claude-spinner 2>/dev/null
tmux set-option -gu @claude-spinner-pid 2>/dev/null
refresh_clients
