# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Config |
|---------|--------|
| zsh | `.zshrc`, `.zprofile` |
| nvim | `.config/nvim/` (LazyVim) |
| tmux | `.config/tmux/tmux.conf`, `.config/tmux/tmux-claude-notify/` (local plugin) |
| sesh | `.config/sesh/sesh.toml`, `dev-layout.sh` (프로젝트 = 세션 3-window) |
| ghostty | `.config/ghostty/config` |
| git | `.gitconfig`, `.config/git/ignore` |
| karabiner | `.config/karabiner/karabiner.json` |
| claude | `.claude/CLAUDE.md` (전역 지침 — 미니멀 유지) |

## Setup

```bash
# 1. Homebrew dependencies
brew install stow tmux neovim jq fzf fd ripgrep bat eza lazygit sesh zoxide ghq
brew install alerter   # 클릭 가능한 macOS 알림 (없으면 osascript로 fallback)

# ghq root를 nvim lazy dev.path(~/.ghq/github.com)와 맞춤
git config --global ghq.root '~/.ghq'

# 2. Clone & stow
git clone https://github.com/juhyeonni/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh nvim tmux sesh git ghostty karabiner claude
```

### zsh 플러그인

`.zshrc`는 [Oh My Zsh](https://ohmyz.sh/)와 몇몇 custom 플러그인을 사용한다. stow로는 설치되지 않으므로 따로 clone 한다 (모두 없어도 셸은 에러 없이 뜨지만, 자동완성·하이라이트가 빠진다).

```bash
# Oh My Zsh 본체
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# custom 플러그인 (ZSH_CUSTOM = ~/.oh-my-zsh/custom)
ZC=~/.oh-my-zsh/custom/plugins
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions      $ZC/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting  $ZC/zsh-syntax-highlighting
git clone --depth 1 https://github.com/MichaelAquilina/zsh-you-should-use $ZC/you-should-use
git clone --depth 1 https://github.com/fdellwing/zsh-bat                  $ZC/zsh-bat
git clone --depth 1 https://github.com/Aloxaf/fzf-tab                     $ZC/fzf-tab
```

`git`·`fzf`는 OMZ 내장 플러그인이라 clone 불필요 (`fzf`는 위 brew 목록에 포함).
플러그인 로드 순서는 `fzf-tab`이 `zsh-autosuggestions` 뒤, `zsh-syntax-highlighting` 앞이어야 한다 (`.zshrc` 주석 참고).

개발 루프(프로젝트 진입 → 코드 → 커밋)는 [WORKFLOW.md](WORKFLOW.md) 참고.

- **tmux 플러그인(TPM)**: 첫 tmux 실행 시 자동으로 clone/설치됨 (`tmux.conf`의 auto-install 블록)
- **폰트**: Ghostty가 `MuxJK` 폰트를 사용 — 별도 설치 필요
- **extrakto**: python3 필요 (macOS 기본 포함)

## tmux-claude-notify (local plugin)

Claude Code 작업 상태를 tmux 윈도우 탭에 표시한다.

- `✻` = Claude 작업 중 / `●N` = 안 보고 있는 윈도우에 알림 N개 (윈도우 진입 시 리셋)
- 데스크톱 알림 클릭 → 해당 tmux 세션/윈도우/pane으로 자동 전환 + 터미널 포커스
- 테마가 그린 `window-status-format`에 조각을 주입하는 방식이라 테마를 바꿔도 동작

tmux 쪽은 `tmux.conf`에서 로드되고, Claude Code 쪽은 `~/.claude/settings.json`에 훅 등록 필요:

```json
"hooks": {
  "Stop":             [{ "matcher": "", "hooks": [{ "type": "command", "command": "$HOME/.config/tmux/tmux-claude-notify/scripts/notify.sh stop", "async": true }] }],
  "Notification":     [{ "matcher": "", "hooks": [{ "type": "command", "command": "$HOME/.config/tmux/tmux-claude-notify/scripts/notify.sh notification", "async": true }] }],
  "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "$HOME/.config/tmux/tmux-claude-notify/scripts/notify.sh busy", "async": true }] }],
  "SessionEnd":       [{ "hooks": [{ "type": "command", "command": "$HOME/.config/tmux/tmux-claude-notify/scripts/notify.sh clear", "async": true }] }]
}
```

옵션 (`tmux.conf`에서 플러그인 `run` 전에 설정):

| Option | Default | 설명 |
|--------|---------|------|
| `@claude-notify-busy-fg` | `yellow` | 작업중 아이콘 색 |
| `@claude-notify-badge-fg` | `red` | 알림 배지 색 |
| `@claude-notify-busy-icon` | `✻` | 작업중 아이콘 (animate off일 때) |
| `@claude-notify-badge-icon` | `●` | 알림 배지 아이콘 |
| `@claude-notify-busy-animate` | `on` | Claude Code 스피너처럼 ~150ms 간격으로 맥동(`· ✢ ✳ ✻ ✽`). busy 동안만 스피너 데몬이 돌고 작업이 모두 끝나면 자동 종료 |
| `@claude-notify-status-right` | `on` | status-right 왼쪽에 에이전트 현황 표시: `✻N`(busy 윈도우) `⧉M`(전체 Claude 세션, `claude agents --json` 15초 캐시) |

주요 tmux 키: `prefix+g` 스크래치 팝업 · `prefix+C-c` Claude 팝업 · `prefix+G` lazygit · `prefix+S` sesh 세션 스위처 · `prefix+tab` extrakto

## Restow (after changes)

```bash
cd ~/dotfiles
stow -R <package>
```
