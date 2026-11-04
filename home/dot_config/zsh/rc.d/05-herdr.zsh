# Scrub tmux leftovers inside a herdr pane.
#
# Starting the herdr server from inside a tmux pane makes it inherit variables like $TMUX and
# hand them down to every pane it creates. They persist until the server restarts.
# Tools that sniff $TMUX to identify the terminal (pi, for one) then mistake herdr for tmux
# and start demanding you fix a tmux config that is not in play.

if [[ -n ${HERDR_ENV:-} ]]; then
  unset TMUX TMUX_PANE TMUX_PLUGIN_MANAGER_PATH TERM_PROGRAM TERM_PROGRAM_VERSION
fi
