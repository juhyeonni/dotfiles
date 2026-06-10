#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$CURRENT_DIR/scripts/translate.sh"

get_tmux_option() {
  local option="$1"
  local default="$2"
  local value
  value=$(tmux show-option -gqv "$option")
  echo "${value:-$default}"
}

TRANSLATE_KEY=$(get_tmux_option "@translate-key" "t")
POPUP_WIDTH=$(get_tmux_option "@translate-popup-width" "60%")
POPUP_HEIGHT=$(get_tmux_option "@translate-popup-height" "40%")

# Bind key in copy-mode-vi: select text then press key to translate
tmux bind-key -T copy-mode-vi "$TRANSLATE_KEY" send-keys -X copy-pipe-and-cancel \
  "pbcopy; tmux display-popup -w $POPUP_WIDTH -h $POPUP_HEIGHT -E '$SCRIPT'"
