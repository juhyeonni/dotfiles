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

## Bootstrap

```bash
# 1. Homebrew dependencies
brew install stow tmux neovim jq fzf fd ripgrep bat eza lazygit sesh zoxide ghq
brew install alerter   # 클릭 가능한 macOS 알림 (없으면 osascript로 fallback)

# 2. Clone & stow
git clone https://github.com/juhyeonni/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh nvim tmux sesh git ghostty karabiner claude
```

stow는 심볼릭 링크만 건다. 각 프로그램의 추가 설치(플러그인 등)는 아래 섹션 참고.
개발 루프(프로젝트 진입 → 코드 → 커밋)는 [WORKFLOW.md](WORKFLOW.md) 참고.

---

## zsh

[Oh My Zsh](https://ohmyz.sh/) + custom 플러그인을 사용한다. stow로는 설치되지 않으므로 따로 clone 한다 (모두 없어도 셸은 에러 없이 뜨지만, 자동완성·하이라이트가 빠진다).

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

- `git`·`fzf`는 OMZ 내장 플러그인이라 clone 불필요 (`fzf`는 brew 목록에 포함).
- 로드 순서: `fzf-tab`이 `zsh-autosuggestions` 뒤, `zsh-syntax-highlighting` 앞이어야 한다 (`.zshrc` 주석 참고).
- `ls`는 `eza`로 alias (brew 목록에 포함). 없으면 기본 `ls`로 fallback.

## nvim

[LazyVim](https://www.lazyvim.org/) 기반. 플러그인은 첫 실행 시 lazy.nvim이 `lazy-lock.json`대로 자동 설치한다.

```bash
# ghq root를 nvim lazy dev.path(~/.ghq/github.com)와 맞춤
git config --global ghq.root '~/.ghq'
```

추가 요구사항은 `.config/nvim/REQUIREMENTS.md` 참고.

## tmux

- **TPM(플러그인 매니저)**: 첫 tmux 실행 시 `tmux.conf`의 auto-install 블록이 자동으로 clone/설치.
- **extrakto**: python3 필요 (macOS 기본 포함).

주요 키: `prefix+g` 스크래치 팝업 · `prefix+C-c` Claude 팝업 · `prefix+G` lazygit · `prefix+S` sesh 세션 스위처 · `prefix+tab` extrakto

### tmux-claude-notify (local plugin)

Claude Code 작업 상태를 tmux 윈도우 탭에 표시한다.

- `✻` = Claude 작업 중 / `●N` = 안 보고 있는 윈도우에 알림 N개 (윈도우 진입 시 리셋)
- 데스크톱 알림 클릭 → 해당 tmux 세션/윈도우/pane으로 자동 전환 + 터미널 포커스
- 테마가 그린 `window-status-format`에 조각을 주입하는 방식이라 테마를 바꿔도 동작

tmux 쪽은 `tmux.conf`에서 로드된다. Claude Code 쪽은 이 저장소가 곧 플러그인 마켓플레이스이므로 `/plugin`으로 설치하면 훅(`hooks/hooks.json`)이 자동 등록된다 — `settings.json`을 손으로 건드릴 필요 없음:

```
/plugin marketplace add ~/dotfiles        # 또는: juhyeonni/dotfiles (GitHub)
/plugin install tmux-claude-notify
```

설치 후 훅이 제대로 걸렸는지 진단:

```bash
~/.config/tmux/tmux-claude-notify/scripts/doctor.sh
```

옵션 (`tmux.conf`에서 플러그인 `run` 전에 설정):

| Option | Default | 설명 |
|--------|---------|------|
| `@claude-notify-busy-fg` | `yellow` | 작업중 아이콘 색 |
| `@claude-notify-badge-fg` | `red` | 알림 배지 색 |
| `@claude-notify-busy-icon` | `✻` | 작업중 아이콘 (animate off일 때) |
| `@claude-notify-badge-icon` | `●` | 알림 배지 아이콘 |
| `@claude-notify-busy-animate` | `on` | Claude Code 스피너처럼 ~150ms 간격으로 맥동(`· ✢ ✳ ✻ ✽`). busy 동안만 스피너 데몬이 돌고 작업이 모두 끝나면 자동 종료 |
| `@claude-notify-status-right` | `on` | status-right 왼쪽에 `✻N`(Claude 작업 중인 윈도우 수) 표시 |

## sesh

`sesh.toml`로 세션을 정의하고 `dev-layout.sh`가 프로젝트당 3-window 레이아웃을 구성한다. tmux에서 `prefix+S`로 세션 스위처를 띄운다. zoxide 히스토리를 활용하므로 `zoxide`(brew 목록 포함) 필요.

## ghostty

- **폰트**: `MuxJK` 폰트 사용 — 별도 설치 필요.

## git

`.gitconfig`(전역 설정)와 `.config/git/ignore`(전역 gitignore). 별도 의존성 없음.

## karabiner

[Karabiner-Elements](https://karabiner-elements.pqrs.org/) 키 리매핑. 앱 설치 후 stow하면 설정이 적용된다.

## claude

Claude Code 전역 지침 `~/.claude/CLAUDE.md` (미니멀 유지). tmux-claude-notify 훅은 [tmux 섹션](#tmux-claude-notify-local-plugin) 참고.

---

## Restow (after changes)

```bash
cd ~/dotfiles
stow -R <package>
```
