#!/usr/bin/env bash
# tmux status-right 세그먼트: Claude busy 윈도우 수
#   ✻N = Claude가 작업 중인 윈도우 수 (실시간, @claude-busy 기반)
# busy 윈도우가 없으면 빈 출력 → 세그먼트 자체가 숨겨진다.
#
# 비용: tmux 변수만 읽으므로 가볍다. (이전엔 전체 세션 수 ⧉도 표시했으나,
# 그건 매 status 갱신마다 무거운 `claude agents --json`을 띄워 느린 머신에서
# claude 프로세스가 무한 누적되는 문제가 있어 제거했다.)

# @claude-busy는 윈도우별 busy pane 카운트 → 0보다 큰 윈도우 수를 센다
busy=$(tmux list-windows -aF '#{@claude-busy}' 2>/dev/null | awk '$1 > 0 { c++ } END { print c + 0 }')

[ "${busy:-0}" -gt 0 ] && printf '✻%s ' "$busy"
