# ====================
# PATH
# ====================
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ====================
# Oh My Zsh
# ====================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="nicoulaj"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  you-should-use
  zsh-bat
)
source $ZSH/oh-my-zsh.sh

# ====================
# Aliases
# ====================
alias term="open -a WezTerm"
alias vim="nvim"
alias GW="cd ~/Workspace"
alias GK="cd ~/Workspace/Kojin"
alias GT="cd ~/Workspace/Team"
alias vz="vim ~/.zshrc"
alias sz="source ~/.zshrc"
alias :q="exit"
alias cld="claude --dangerously-skip-permissions"
alias ccc="claude"
alias ccu="bunx ccusage@latest"   # Claude Code 토큰/비용 분석
alias clr="clear"

alias python='python3'

# ====================
# Editor
# ====================
export EDITOR="nvim"

# ====================
# Rust (rustup + cargo)
# ====================
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# ====================
# Deno
# ====================
. "/Users/juhyeonlee/.deno/env"

# ====================
# Node (fnm)
# ====================
FNM_PATH="/Users/juhyeonlee/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
fi
eval "$(fnm env)"
FNM_COREPACK_ENABLED=true

# ====================
# Docker
# ====================
fpath=(/Users/juhyeonlee/.docker/completions $fpath)
autoload -Uz compinit
compinit

# ====================
# Misc
# ====================
. "$HOME/.local/bin/env"

# ====================
# SDKMAN (must be at the end)
# ====================
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ====================
# Google Cloud SDK
# ====================
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# ====================
# Bun
# ====================
[ -s "/Users/juhyeonlee/.bun/_bun" ] && source "/Users/juhyeonlee/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ====================
# zoxide (smart cd) — sesh 세션 매니저가 z 히스토리를 활용
# ====================
command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"

# ====================
# tmux (auto-attach)
# ====================
# -A: 세션이 있으면 attach, 없으면 생성 (고아 세션 누적 방지)
# exec: tmux 종료 시 터미널도 닫힘
# Ghostty quick terminal에서는 tmux 미사용
if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -z "$GHOSTTY_QUICK_TERMINAL" ]; then
  exec tmux new -A -s main
fi

