# ====================
# PATH
# ====================
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ====================
# Oh My Zsh
# ====================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="nicoulaj"

# fzf-tab은 zsh-autosuggestions 뒤, zsh-syntax-highlighting 앞에 와야 함
plugins=(
  git
  fzf
  zsh-autosuggestions
  fzf-tab
  zsh-syntax-highlighting
  you-should-use
  zsh-bat
)
[ -f "$ZSH/oh-my-zsh.sh" ] && source $ZSH/oh-my-zsh.sh

# ====================
# fzf-tab
# ====================
# 그룹 간 이동(파일/디렉토리 그룹) — < > 키
zstyle ':fzf-tab:*' switch-group '<' '>'
# 선택 시 미리보기: 디렉토리는 eza 트리, 그 외는 기본
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
# 완성 후보에 색상 적용 (LS_COLORS 사용)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

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

# eza (modern ls) — 설치된 경우에만 ls를 대체
if command -v eza &> /dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -la --icons --git --group-directories-first"
  alias la="eza -a --icons --group-directories-first"
  alias lt="eza --tree --level=2 --icons"
fi

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
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# ====================
# Node (fnm)
# ====================
FNM_PATH="$HOME/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
fi
if command -v fnm &> /dev/null; then
  eval "$(fnm env)"
  FNM_COREPACK_ENABLED=true
fi

# ====================
# Docker
# ====================
[ -d "$HOME/.docker/completions" ] && fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit

# ====================
# Misc
# ====================
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

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
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
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

