# ====================
# PATH
# ====================
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ====================
# Oh My Zsh
# ====================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="nicoulaj"

# 붙여넣기 시 URL/경로 quoting 매직 비활성화 — 구형(인텔) 머신에서 붙여넣기 렉 방지
DISABLE_MAGIC_FUNCTIONS=true

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

# Docker completion을 fpath에 추가 (omz의 compinit이 한 번에 픽업하도록 source 이전에 설정)
[ -d "$HOME/.docker/completions" ] && fpath=($HOME/.docker/completions $fpath)

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
# ghq → zoxide 브리지
# ====================
# ghq 로 받은 모든 리포를 zoxide 에 등록한다. herdr 의 workspace-jump 스크립트가
# zoxide 를 후보 소스로 쓰므로, 방문 이력이 없는 갓 clone 한 리포도 즉시
# `prefix + S` picker 에 노출된다. → 리포 진입점을 이 키 하나로 통일.
if command -v ghq &> /dev/null && command -v zoxide &> /dev/null; then
  ghq-zoxide-sync() {
    ghq list -p | while IFS= read -r repo; do zoxide add "$repo"; done
  }
  # ghq get 직후 자동 동기화 (clone 하자마자 picker 가 인식)
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
# zoxide (smart cd) — herdr workspace-jump 가 z 히스토리를 활용
# ====================
command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"

# ====================
# rc.d — 선택 계층 로드
# ====================
# 존재하는 조각만 번호 순으로 읽는다. 개발 런타임(rust/node/deno/bun/java/gcloud)
# 처럼 머신마다 있을 수도 없을 수도 있는 것은 전부 여기로 뺐다.
# 셸 코어(이 파일)는 런타임의 존재를 모른다 — 부트스트랩과 개발환경 구성이
# 서로 다른 단계이기 때문이다.
# (N) = 매치가 없어도 에러 내지 않는 zsh glob qualifier
for _rc in ~/.config/zsh/rc.d/*.zsh(N); do source "$_rc"; done
unset _rc

# ====================
# 이 머신 전용 설정
# ====================
# 레포에 들어가지 않는다(.gitignore). 임시 PATH, 회사 도구, 실험용 alias 등.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ====================
# herdr (auto-attach)
# ====================
# --session main: 세션이 있으면 attach, 없으면 생성
# exec: herdr 종료 시 터미널도 닫힘
# HERDR_ENV: herdr 가 관리하는 pane 안에서는 재진입하지 않는다
#            (herdr 는 기본적으로 중첩 실행을 막는다 — experimental.allow_nested)
# Ghostty quick terminal에서는 herdr 미사용
if command -v herdr &> /dev/null && [ -z "$HERDR_ENV" ] && [ -z "$GHOSTTY_QUICK_TERMINAL" ]; then
  exec herdr --session main
fi

