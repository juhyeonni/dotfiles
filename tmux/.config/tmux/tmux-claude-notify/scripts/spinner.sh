#!/usr/bin/env bash
# 스피너 데몬: busy 윈도우가 하나라도 있는 동안 @claude-spinner 옵션을
# ~150ms 간격으로 갱신하고 클라이언트 상태바를 강제 리프레시한다.
# busy 윈도우가 없어지면 스스로 종료. notify.sh(busy)가 기동한다.

FRAMES=(· ✢ ✳ ✻ ✽ ✻ ✳ ✢)
INTERVAL=0.15

# TTL: 마지막 활동(@claude-busy-ts) 이후 이 시간(초)이 지나도록 갱신이 없으면
# busy 를 stale 로 보고 회수한다. 취소/인터럽트는 Stop 훅이 안 와서 busy 가
# 박제되는데(Claude Code 에 cancel 훅 없음), tick 하트비트가 끊긴 걸로 감지한다.
TTL=$(tmux show-option -gqv @claude-notify-busy-ttl 2>/dev/null)
TTL=${TTL:-90}

# stale busy 윈도우 회수: now - @claude-busy-ts > TTL 이면 그 윈도우의 busy 해제.
sweep_stale() {
  local now line win ts
  now=$(date +%s)
  while read -r win ts; do
    [ -n "$win" ] || continue
    [ -n "$ts" ] || continue
    if [ "$((now - ts))" -gt "$TTL" ]; then
      tmux set-option -wq -t "$win" @claude-busy 0 2>/dev/null
      tmux set-option -wq -t "$win" @claude-busy-panes "" 2>/dev/null
    fi
  done < <(tmux list-windows -aF '#{window_id} #{@claude-busy} #{@claude-busy-ts}' 2>/dev/null \
            | awk '$2 > 0 && $3 != "" { print $1, $3 }')
}

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

# animate off 면 프레임을 그리지 않고 sweep 만 하므로 느슨하게 돈다.
animate=$(tmux show-option -gqv @claude-notify-busy-animate 2>/dev/null)
animate=${animate:-on}
[ "$animate" = "on" ] || INTERVAL=2

i=0
while :; do
  # 먼저 stale busy(취소 후 방치)를 회수한 뒤 남은 busy 를 평가한다.
  sweep_stale

  # tmux 서버가 죽었거나 busy 윈도우가 없으면 종료 (@claude-busy는 카운트)
  busy=$(tmux list-windows -aF '#{@claude-busy}' 2>/dev/null) || break
  echo "$busy" | awk '$1 > 0 { found = 1 } END { exit !found }' || break

  if [ "$animate" = "on" ]; then
    tmux set-option -gq @claude-spinner "${FRAMES[$((i % ${#FRAMES[@]}))]}" 2>/dev/null
    refresh_clients
    i=$((i + 1))
  fi
  sleep "$INTERVAL"
done

tmux set-option -gu @claude-spinner 2>/dev/null
tmux set-option -gu @claude-spinner-pid 2>/dev/null
refresh_clients
