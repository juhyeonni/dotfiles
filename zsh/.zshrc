# ====================
# PATH
# ====================
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ====================
# Oh My Zsh
# ====================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="nicoulaj"

# Disable URL/path quoting magic on paste — prevents paste lag on older (Intel) machines
DISABLE_MAGIC_FUNCTIONS=true

# fzf-tab must come after zsh-autosuggestions and before zsh-syntax-highlighting
plugins=(
  git
  fzf
  zsh-autosuggestions
  fzf-tab
  zsh-syntax-highlighting
  you-should-use
  zsh-bat
)

# Add Docker completion to fpath (set before sourcing omz so its compinit picks it up in one pass)
[ -d "$HOME/.docker/completions" ] && fpath=($HOME/.docker/completions $fpath)

[ -f "$ZSH/oh-my-zsh.sh" ] && source $ZSH/oh-my-zsh.sh

# ====================
# fzf-tab
# ====================
# Move between groups (files/directories) — the < > keys
zstyle ':fzf-tab:*' switch-group '<' '>'
# Preview on selection: an eza tree for directories, the default otherwise
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
# Colorize completion candidates (uses LS_COLORS)
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
alias ccu="bunx ccusage@latest"   # Claude Code token/cost breakdown
alias clr="clear"

alias python='python3'

# eza (modern ls) — replaces ls only when installed
if command -v eza &> /dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -la --icons --git --group-directories-first"
  alias la="eza -a --icons --group-directories-first"
  alias lt="eza --tree --level=2 --icons"
fi

# ====================
# ghq -> zoxide bridge
# ====================
# Register ghq-fetched repos with zoxide. workspace-jump draws its candidates from zoxide,
# so a freshly cloned repo shows up in the picker with no visit history.
if command -v ghq &> /dev/null && command -v zoxide &> /dev/null; then
  ghq-zoxide-sync() {
    ghq list -p | while IFS= read -r repo; do zoxide add "$repo"; done
  }
  # Sync right after ghq get, so the picker sees the clone immediately
  ghq() {
    command ghq "$@"; local ret=$?
    [[ "$1" == "get" ]] && ghq-zoxide-sync
    return $ret
  }
fi

# ====================
# Editor
# ====================
export EDITOR="nvim"

# ====================
# zoxide (smart cd) — herdr workspace-jump reuses the z history
# ====================
command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"

# ====================
# rc.d — optional layer
# ====================
# Sources only the fragments that exist, in numeric order. Anything that may or may not be
# present per machine — dev runtimes (rust/node/deno/bun/java/gcloud) — was moved here.
# The shell core (this file) knows nothing about runtimes: bootstrapping the shell and
# setting up a dev environment are separate stages.
# (N) = zsh glob qualifier that stays silent when nothing matches
for _rc in ~/.config/zsh/rc.d/*.zsh(N); do source "$_rc"; done
unset _rc

# ====================
# Machine-local settings
# ====================
# Never enters the repo (.gitignore). Temporary PATH entries, work tools, throwaway aliases.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ====================
# herdr (auto-attach)
# ====================
# --session main: attach if it exists, create otherwise. exec: quitting herdr closes the terminal.
# HERDR_ENV means we are inside a herdr-managed pane — guards against nesting.
if command -v herdr &> /dev/null && [ -z "$HERDR_ENV" ] && [ -z "$GHOSTTY_QUICK_TERMINAL" ]; then
  exec herdr --session main
fi

