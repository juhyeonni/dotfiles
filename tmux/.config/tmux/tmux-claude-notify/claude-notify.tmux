#!/usr/bin/env bash
# tmux-claude-notify
# Claude Code 작업 상태를 tmux 윈도우 탭에 표시하는 플러그인.
#   ✻  : Claude 작업 중 (@claude-busy)
#   ●N : 안 보고 있는 윈도우에 알림 N개 (@claude-notify-count)
#
# 테마가 그린 window-status-format을 덮어쓰지 않고 조각만 덧붙이는(inject)
# 방식이라 테마를 바꿔도 그대로 동작한다. 테마 플러그인 로드 후에 실행할 것.
#
# Options:
#   @claude-notify-busy-fg      busy 아이콘 색 (default: yellow)
#   @claude-notify-badge-fg     배지 색 (default: red)
#   @claude-notify-busy-icon    (default: ✻, animate off일 때 사용)
#   @claude-notify-badge-icon   (default: ●)
#   @claude-notify-busy-animate on|off (default: on)
#       on이면 Claude Code 스피너처럼 ~150ms 간격으로 맥동(· ✢ ✳ ✻ ✽).
#       busy 동안만 스피너 데몬(scripts/spinner.sh)이 돌며 @claude-spinner
#       옵션 갱신 + refresh-client -S로 상태바를 강제 리프레시한다.
#
# Claude Code 쪽 등록 (settings.json hooks):
#   UserPromptSubmit → scripts/notify.sh busy
#   Stop             → scripts/notify.sh stop
#   Notification     → scripts/notify.sh notification
#   SessionEnd       → scripts/notify.sh clear

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local value
  value=$(tmux show-option -gqv "$1")
  echo "${value:-$2}"
}

busy_fg=$(get_tmux_option "@claude-notify-busy-fg" "yellow")
badge_fg=$(get_tmux_option "@claude-notify-badge-fg" "red")
busy_icon=$(get_tmux_option "@claude-notify-busy-icon" "✻")
badge_icon=$(get_tmux_option "@claude-notify-badge-icon" "●")
busy_animate=$(get_tmux_option "@claude-notify-busy-animate" "on")

if [ "$busy_animate" = "on" ]; then
  # 데몬이 살아있으면 현재 프레임, 죽었으면 정적 아이콘으로 fallback
  busy_icon="#{?@claude-spinner,#{@claude-spinner},${busy_icon}}"
fi

busy_frag="#{?@claude-busy, #[fg=${busy_fg}]${busy_icon}#[default],}"
badge_frag="#{?@claude-notify-count, #[fg=${badge_fg}]${badge_icon}#{E:@claude-notify-count}#[default],}"

# 포맷에 조각을 주입한다 (이미 주입돼 있으면 생략 → reload 시 중복 방지).
# 포맷 끝이 '스타일블록 + 구분자 글리프'(powerline chevron 등)면 그 앞에
# 삽입해서 아이콘이 pill 내부에 표시되도록 한다.
inject() {
  local opt="$1" cur
  cur=$(tmux show-option -gv "$opt" 2>/dev/null)
  case "$cur" in
  *@claude-busy*) return ;;
  esac
  if [[ "$cur" =~ ^(.*)(#\[[^]]*\][^#]*)$ ]]; then
    tmux set-option -g "$opt" "${BASH_REMATCH[1]}${busy_frag}${badge_frag}${BASH_REMATCH[2]}"
  else
    tmux set-option -g "$opt" "${cur}${busy_frag}${badge_frag}"
  fi
}

inject window-status-format
inject window-status-current-format

# 윈도우에 들어오면 알림 카운트 리셋 (busy는 포커스와 무관하므로 유지)
reset_cmd='set-option -wq @claude-notify-count 0; set-option -wq @claude-notify-latest 0'
tmux set-hook -g window-pane-changed "$reset_cmd"
tmux set-hook -g session-window-changed "$reset_cmd"
