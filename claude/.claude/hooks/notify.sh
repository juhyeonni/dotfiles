#!/bin/bash
# Claude Code notification helper
# stdin: JSON from hook, $1: stop | notification | busy | clear
# - busy/clear: tmux 윈도우 탭에 작업중(✻) 표시 토글만 수행
# - stop/notification: macOS 알림 + tmux 윈도우 탭 배지(●N)
# 알림 클릭 시 Ghostty 포커스 + tmux 윈도우/pane 자동 전환
# Deps: jq, alerter(brew, 없으면 osascript fallback), tmux(optional)

input=$(cat)
event="$1"

# --- tmux helpers ---
tmux_win_id() {
  [ -n "$TMUX_PANE" ] || return 1
  tmux display-message -p -t "$TMUX_PANE" '#{window_id}' 2>/dev/null
}

set_busy() {
  local win_id
  win_id=$(tmux_win_id) || return 0
  tmux set-option -wq -t "$win_id" @claude-busy "$1" 2>/dev/null
}

case "$event" in
  busy)
    set_busy 1
    exit 0
    ;;
  clear)
    set_busy 0
    exit 0
    ;;
  stop)
    msg=$(echo "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null | head -c 300)
    title="Claude Code"
    sound="Glass"
    fallback="작업이 완료됐어요"
    ;;
  notification)
    msg=$(echo "$input" | jq -r '.message // empty' 2>/dev/null | head -c 300)
    title="Claude Code"
    sound="Ping"
    fallback="입력이 필요해요"
    ;;
esac

# 턴 종료/입력 대기 → 작업중 표시 해제
set_busy 0

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

# --- 알림 클릭 시 Ghostty 포커스 (백그라운드) ---
(
  # 알림 발송 (alerter는 클릭/닫기까지 블로킹)
  if command -v alerter &>/dev/null; then
    result=$(alerter \
      --title "$title" \
      --message "$msg" \
      --sound "$sound" \
      --timeout 10 \
      --json 2>/dev/null)

    # 클릭 시 tmux 전환 + Ghostty 활성화
    if echo "$result" | grep -q "contentsClicked"; then
      if [ -n "$TMUX_PANE" ]; then
        target_session=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)
        if [ -n "$target_session" ]; then
          tmux switch-client -t "$target_session" 2>/dev/null
        fi
        tmux select-window -t "$TMUX_PANE" 2>/dev/null
        tmux select-pane -t "$TMUX_PANE" 2>/dev/null
      fi
      open -a Ghostty
    fi
  else
    # fallback: alerter 없으면 osascript
    msg_escaped=$(echo "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
    osascript -e "display notification \"$msg_escaped\" with title \"$title\" sound name \"$sound\""
  fi
) &
