#!/usr/bin/env bash
# tmux-claude-notify: Claude Code hook entry point
# stdin: JSON from hook, $1: stop | notification | busy | clear
# - busy/clear: tmux 윈도우 탭에 작업중(✻) 표시 토글만 수행
# - stop/notification: 데스크톱 알림 + tmux 윈도우 탭 배지(●N)
#   알림 클릭 시 터미널 앱 포커스 + tmux 윈도우/pane 자동 전환 (macOS+alerter)
# Deps: jq | macOS: alerter(brew, 없으면 osascript) | Linux: notify-send

input=$(cat)
event="$1"

# --- tmux helpers ---
tmux_win_id() {
  [ -n "$TMUX_PANE" ] || return 1
  tmux display-message -p -t "$TMUX_PANE" '#{window_id}' 2>/dev/null
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# busy는 윈도우별 "busy pane 목록"(@claude-busy-panes)으로 관리한다.
# - 같은 윈도우에서 Claude Code를 여러 pane으로 돌려도 하나가 끝났다고
#   스피너가 꺼지지 않음 (@claude-busy = busy pane 수)
# - pane 단위 추가/제거가 멱등이라 훅 이벤트가 중복/누락돼도 안전
# - 갱신 때마다 죽은 pane을 목록에서 걸러내 stale busy를 자동 회복
set_busy() {
  local win_id animate panes p live count
  win_id=$(tmux_win_id) || return 0
  panes=$(tmux show-option -wqv -t "$win_id" @claude-busy-panes 2>/dev/null)

  if [ "$1" = "1" ]; then
    case " $panes " in
    *" $TMUX_PANE "*) : ;;
    *) panes="${panes:+$panes }$TMUX_PANE" ;;
    esac
  else
    panes=$(echo " $panes " | sed "s/ $TMUX_PANE / /g")
  fi

  # 살아있는 pane만 유지
  # (display-message는 죽은 타깃에도 exit 0으로 fallback하므로 has-session 사용)
  live=""
  for p in $panes; do
    if tmux has-session -t "$p" 2>/dev/null; then
      live="${live:+$live }$p"
    fi
  done

  count=0
  for p in $live; do count=$((count + 1)); done
  tmux set-option -wq -t "$win_id" @claude-busy-panes "$live" 2>/dev/null
  tmux set-option -wq -t "$win_id" @claude-busy "$count" 2>/dev/null

  # 작업 시작 시: 활동 타임스탬프 기록 + 데몬 기동.
  # 데몬은 animate 와 무관하게 띄운다 — 프레임 애니메이션뿐 아니라
  # stale busy(@claude-busy-ts 가 TTL 초과) 회수도 담당하기 때문이다.
  # (singleton 이라 중복 기동은 데몬 쪽에서 무시된다)
  if [ "$count" -gt 0 ]; then
    tmux set-option -wq -t "$win_id" @claude-busy-ts "$(date +%s)" 2>/dev/null
    nohup "$SCRIPT_DIR/spinner.sh" >/dev/null 2>&1 &
  fi
}

# tick: 활동 하트비트. 이미 busy 인 윈도우의 타임스탬프만 갱신한다(경량).
# PreToolUse/PostToolUse 마다 불려서 긴 멀티툴 작업이 TTL 로 만료되지 않게 한다.
# busy 가 아니면 아무것도 안 함(턴 밖 호출로 인한 허위 busy 방지).
tick_busy() {
  local win_id count
  win_id=$(tmux_win_id) || return 0
  count=$(tmux show-option -wqv -t "$win_id" @claude-busy 2>/dev/null)
  [ "${count:-0}" -gt 0 ] 2>/dev/null || return 0
  tmux set-option -wq -t "$win_id" @claude-busy-ts "$(date +%s)" 2>/dev/null
}

# 클릭 시 포커스할 터미널 앱 자동 감지 (macOS)
focus_terminal() {
  if [ -n "$__CFBundleIdentifier" ]; then
    open -b "$__CFBundleIdentifier" 2>/dev/null && return
  fi
  case "$TERM_PROGRAM" in
    ghostty) open -a Ghostty 2>/dev/null ;;
    iTerm.app) open -a iTerm 2>/dev/null ;;
    Apple_Terminal) open -a Terminal 2>/dev/null ;;
    WezTerm) open -a WezTerm 2>/dev/null ;;
  esac
}

case "$event" in
  busy)
    set_busy 1
    exit 0
    ;;
  tick)
    tick_busy
    exit 0
    ;;
  clear)
    set_busy 0
    exit 0
    ;;
  stop)
    # 턴 정상 종료 → 작업중 표시 해제
    set_busy 0
    msg=$(echo "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null | head -c 300)
    title="Claude Code"
    sound="Glass"
    fallback="작업이 완료됐어요"
    ;;
  notification)
    # 입력 대기/권한 프롬프트. busy 는 유지한다 — 승인 후 Claude 가 계속
    # 일하므로 여기서 끄면 스피너가 잘못 꺼진다. stale 는 TTL 이 회수.
    msg=$(echo "$input" | jq -r '.message // empty' 2>/dev/null | head -c 300)
    title="Claude Code"
    sound="Ping"
    fallback="입력이 필요해요"
    ;;
  *)
    exit 0
    ;;
esac

# Strip markdown to plain text (preserve newlines) — BSD sed compatible
if [ -n "$msg" ]; then
  msg=$(echo "$msg" | sed \
    -e 's/^#\{1,6\} //' \
    -e 's/\*\*\([^*]*\)\*\*/\1/g' \
    -e 's/\*\([^*]*\)\*/\1/g' \
    -e 's/__\([^_]*\)__/\1/g' \
    -e 's/_\([^_]*\)_/\1/g' \
    -e 's/`\([^`]*\)`/\1/g' \
    -e 's/```[a-z]*//g' \
    -e 's/```//g' \
    -e 's/^[[:space:]]*[-*+] /• /g' \
    -e 's/\[\([^]]*\)\]([^)]*)/\1/g' \
    -e 's/^> //' \
    -e '/^---$/d' \
    -e '/^___$/d' \
    -e '/^\*\*\*$/d')
fi
[ -z "$msg" ] && msg="$fallback"

# --- tmux 윈도우에 알림 카운트 증가 (보고 있지 않은 윈도우만) ---
if [ -n "$TMUX_PANE" ]; then
  win_id=$(tmux_win_id)
  if [ -n "$win_id" ]; then
    # 해당 윈도우가 현재 활성 + 세션에 클라이언트가 붙어 있으면 이미 보고 있는 것 → 배지 생략
    is_visible=$(tmux display-message -p -t "$TMUX_PANE" '#{&&:#{window_active},#{session_attached}}' 2>/dev/null)
    if [ "$is_visible" != "1" ]; then
      cur=$(tmux show-option -wqv -t "$win_id" @claude-notify-count 2>/dev/null)
      cur=${cur:-0}
      tmux set-option -wq -t "$win_id" @claude-notify-count $((cur + 1)) 2>/dev/null
      tmux set-option -wq -t "$win_id" @claude-notify-latest 1 2>/dev/null
    fi
  fi
fi

# --- 데스크톱 알림 (백그라운드) ---
(
  if command -v alerter &>/dev/null; then
    # alerter는 클릭/닫기까지 블로킹 → 클릭 시 tmux 전환 + 터미널 포커스
    result=$(alerter \
      --title "$title" \
      --message "$msg" \
      --sound "$sound" \
      --timeout 10 \
      --json 2>/dev/null)

    if echo "$result" | grep -q "contentsClicked"; then
      if [ -n "$TMUX_PANE" ]; then
        target_session=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)
        if [ -n "$target_session" ]; then
          tmux switch-client -t "$target_session" 2>/dev/null
        fi
        tmux select-window -t "$TMUX_PANE" 2>/dev/null
        tmux select-pane -t "$TMUX_PANE" 2>/dev/null
      fi
      focus_terminal
    fi
  elif command -v osascript &>/dev/null; then
    msg_escaped=$(echo "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
    osascript -e "display notification \"$msg_escaped\" with title \"$title\" sound name \"$sound\""
  elif command -v notify-send &>/dev/null; then
    notify-send "$title" "$msg"
  fi
) &
