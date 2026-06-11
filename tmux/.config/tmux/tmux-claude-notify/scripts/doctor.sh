#!/usr/bin/env bash
# tmux-claude-notify 진단 스크립트.
# 새 머신에서 "작업중 스피너가 안 움직인다" 류 문제를 한 번에 점검한다.
#   사용법: tmux 안에서 실행. Claude가 실제로 작업 중일 때 돌리면 라이브 항목까지 확인됨.
#     ~/.config/tmux/tmux-claude-notify/scripts/doctor.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- 출력 헬퍼 ---
pass()  { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn()  { printf '  \033[33m!\033[0m %s\n' "$1"; }
fail()  { printf '  \033[31m✗\033[0m %s\n' "$1"; }
info()  { printf '    \033[2m%s\033[0m\n' "$1"; }
head()  { printf '\n\033[1m%s\033[0m\n' "$1"; }

issues=0
note_fail() { issues=$((issues + 1)); }

# --- 0. tmux 안에서 실행 중인지 ---
head "0. 환경"
if [ -z "$TMUX" ]; then
  fail "tmux 세션 밖에서 실행됨 — tmux 안에서 다시 실행하세요."
  exit 1
fi
pass "tmux 세션 안에서 실행 중"

# --- 1. tmux 버전 (#{@user-option} 포맷은 3.0+ 필요) ---
head "1. tmux 버전"
ver=$(tmux -V | awk '{print $2}')
major=$(echo "$ver" | sed 's/[^0-9.].*//' | cut -d. -f1)
if [ "${major:-0}" -ge 3 ] 2>/dev/null; then
  pass "tmux $ver (>= 3.0)"
else
  fail "tmux $ver — 3.0 미만은 #{@claude-spinner} 포맷 미지원 (정적 아이콘도 안 뜸)"
  note_fail
fi

# --- 2. 스크립트 실행권한 + bash ---
head "2. 스크립트 / 의존성"
for s in notify.sh spinner.sh agents_status.sh; do
  if [ -x "$SCRIPT_DIR/$s" ]; then
    pass "$s 실행권한 있음"
  else
    fail "$s 실행권한 없음 → 데몬이 안 뜸:  chmod +x $SCRIPT_DIR/$s"
    note_fail
  fi
done
if command -v bash >/dev/null 2>&1; then pass "bash 있음"; else fail "bash 없음 (데몬 셸)"; note_fail; fi
if command -v jq   >/dev/null 2>&1; then pass "jq 있음";   else warn "jq 없음 — 알림 메시지 파싱 불가 (스피너와는 무관)"; fi

# --- 3. 플러그인 로드 여부 (포맷에 조각이 주입됐나) ---
head "3. 플러그인 로드"
fmt=$(tmux show-option -gv window-status-format 2>/dev/null)
case "$fmt" in
  *@claude-busy*) pass "window-status-format 에 busy 조각 주입됨" ;;
  *) fail "포맷에 주입 안 됨 → claude-notify.tmux 미로드 (tmux.conf 의 run 라인/순서 확인)"; note_fail ;;
esac

# --- 4. busy-animate 옵션 ---
head "4. 애니메이션 옵션"
animate=$(tmux show-option -gqv @claude-notify-busy-animate)
if [ "${animate:-on}" = "off" ]; then
  fail "@claude-notify-busy-animate = off → 정적 아이콘만 사용. on 으로 바꾸세요."
  note_fail
else
  pass "@claude-notify-busy-animate = ${animate:-on (default)}"
fi

# --- 5. 스피너 데몬 PID 상태 (stale 여부) ---
head "5. 스피너 데몬"
pid=$(tmux show-option -gqv @claude-spinner-pid)
if [ -z "$pid" ]; then
  info "@claude-spinner-pid 없음 (busy 아닐 때 정상 — 데몬은 작업 시작 시 기동)"
elif kill -0 "$pid" 2>/dev/null; then
  pass "데몬 PID $pid 살아있음"
else
  fail "PID $pid 가 죽었는데 옵션이 남음 = stale → 새 데몬이 싱글톤 체크에 걸려 종료됨"
  info "해제:  tmux set-option -gu @claude-spinner-pid"
  note_fail
fi

# --- 6. Claude Code 훅 등록 (settings.json — stow 대상 아님) ---
head "6. Claude Code 훅 (~/.claude/settings.json)"
found_hook=0
for f in "$HOME/.claude/settings.json" "$HOME/.claude/settings.local.json"; do
  [ -f "$f" ] || continue
  if grep -q 'notify.sh busy' "$f" 2>/dev/null; then
    pass "busy 훅 등록됨 ($(basename "$f"))"
    found_hook=1
    for ev in stop notification clear; do
      grep -q "notify.sh $ev" "$f" 2>/dev/null \
        && pass "$ev 훅 등록됨" \
        || warn "$ev 훅 없음 (스피너엔 무관하나 알림이 빠짐)"
    done
    break
  fi
done
if [ "$found_hook" -eq 0 ]; then
  fail "busy 훅 미등록 — 이게 없으면 작업중 표시 자체가 안 됨"
  info "README 의 hooks 블록을 ~/.claude/settings.json 에 추가하세요 (stow 안 됨, 머신마다 수동)"
  note_fail
fi

# --- 7. 라이브 확인 (Claude 작업 중일 때만 의미 있음) ---
head "7. 라이브 상태"
busy_total=$(tmux list-windows -aF '#{@claude-busy}' 2>/dev/null | awk '{s+=$1} END{print s+0}')
if [ "${busy_total:-0}" -gt 0 ]; then
  pass "busy 윈도우 감지됨 (@claude-busy 합계=$busy_total)"
  info "@claude-spinner 값이 바뀌는지 2초간 관찰..."
  seen=""
  changed=0
  for _ in $(seq 1 8); do
    v=$(tmux show-option -gqv @claude-spinner)
    case "$seen" in
      *"|$v|"*) : ;;
      *) [ -n "$seen" ] && changed=1; seen="$seen|$v|" ;;
    esac
    sleep 0.25
  done
  if [ "$changed" -eq 1 ]; then
    pass "@claude-spinner 프레임이 변함 → 애니메이션 정상 동작 중"
  else
    fail "@claude-spinner 값이 안 바뀜 → 데몬이 안 돌거나 즉시 죽음 (위 2·5번 확인)"
    note_fail
  fi
else
  info "지금 busy 윈도우 없음 — Claude 에게 작업을 시킨 상태(처리 중)로 만든 뒤 다시 실행하면"
  info "스피너 갱신까지 확인됩니다."
fi

# --- 요약 ---
head "요약"
if [ "$issues" -eq 0 ]; then
  pass "발견된 문제 없음."
else
  fail "$issues 개 항목에서 문제 발견 — 위 ✗ 표시를 확인하세요."
fi
exit 0
