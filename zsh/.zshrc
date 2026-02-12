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
alias cld="claude"
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
# tmux (auto-attach)
# ====================
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux new
fi

