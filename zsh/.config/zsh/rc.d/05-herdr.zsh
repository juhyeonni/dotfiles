# herdr pane 안에서는 tmux 흔적을 지운다.
#
# herdr 서버를 tmux pane 안에서 처음 띄우면 $TMUX 같은 변수를 상속하고, 그걸
# 자기가 만드는 모든 pane 에 물려준다. 서버를 재시작할 때까지 남는다.
# pi 처럼 $TMUX 로 터미널을 판별하는 도구가 herdr 를 tmux 로 오인해서
# 엉뚱한 tmux 설정을 고치라고 요구한다.

if [[ -n ${HERDR_ENV:-} ]]; then
  unset TMUX TMUX_PANE TMUX_PLUGIN_MANAGER_PATH TERM_PROGRAM TERM_PROGRAM_VERSION
fi
