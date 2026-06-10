#!/usr/bin/env bash
# tmux status-right 세그먼트: Claude 에이전트 현황
#   ✻N = busy 윈도우 수 (실시간, @claude-busy 기반)
#   ⧉M = 전체 Claude Code 세션 수 (claude agents --json, 15초 캐시)
# 아무것도 없으면 빈 출력 → 세그먼트 자체가 숨겨진다.

CACHE="${TMPDIR:-/tmp}/tmux-claude-notify-agents.cache"
TTL=15

# @claude-busy는 윈도우별 busy pane 카운트 → 0보다 큰 윈도우 수를 센다
busy=$(tmux list-windows -aF '#{@claude-busy}' 2>/dev/null | awk '$1 > 0 { c++ } END { print c + 0 }')

total=""
now=$(date +%s)
if [ -f "$CACHE" ]; then
  read -r ts cached < "$CACHE" 2>/dev/null
  if [ $((now - ${ts:-0})) -le $TTL ]; then
    total="$cached"
  fi
fi
if [ -z "$total" ] && command -v claude >/dev/null 2>&1; then
  # 에이전트 객체마다 "cwd" 필드가 하나씩 있다.
  # grep -o + wc -l 이라 compact JSON(한 줄)이어도 정확히 센다.
  total=$(claude agents --json 2>/dev/null | grep -o '"cwd"' | wc -l | tr -d ' ')
  # 동시 실행 대비 원자적 쓰기
  echo "$now $total" >"$CACHE.tmp.$$" 2>/dev/null && mv -f "$CACHE.tmp.$$" "$CACHE" 2>/dev/null
fi

out=""
[ "${busy:-0}" -gt 0 ] && out="✻${busy}"
if [ -n "$total" ] && [ "$total" -gt 0 ] 2>/dev/null; then
  [ -n "$out" ] && out="$out "
  out="${out}⧉${total}"
fi
[ -n "$out" ] && printf '%s ' "$out"
