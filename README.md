# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Config |
|---------|--------|
| zsh | `.zshrc`, `.zprofile` |
| nvim | `.config/nvim/` (LazyVim) |
| tmux | `.config/tmux/tmux.conf`, `.config/tmux/tmux-translate/` (local plugin) |
| ghostty | `.config/ghostty/config` |
| git | `.gitconfig`, `.config/git/ignore` |
| karabiner | `.config/karabiner/karabiner.json` |
| claude | `.claude/hooks/notify.sh` (Claude Code 알림 → macOS 알림 + tmux 탭 배지/작업중 표시) |

## Setup

```bash
# 1. Homebrew dependencies
brew install stow tmux neovim jq fzf fd ripgrep bat
brew install alerter   # 클릭 가능한 macOS 알림 (없으면 osascript로 fallback)

# 2. Clone & stow
git clone https://github.com/juhyeonni/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh nvim tmux git ghostty karabiner claude
```

- **tmux 플러그인(TPM)**: 첫 tmux 실행 시 자동으로 clone/설치됨 (`tmux.conf`의 auto-install 블록)
- **폰트**: Ghostty가 `MuxJK` 폰트를 사용 — 별도 설치 필요
- **extrakto**: python3 필요 (macOS 기본 포함)

## Claude Code 연동

`claude` 패키지는 훅 스크립트만 포함한다. `~/.claude/settings.json`에 아래 훅 등록 필요:

```json
"hooks": {
  "Stop":             [{ "matcher": "", "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/notify.sh stop", "async": true }] }],
  "Notification":     [{ "matcher": "", "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/notify.sh notification", "async": true }] }],
  "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/notify.sh busy", "async": true }] }],
  "SessionEnd":       [{ "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/notify.sh clear", "async": true }] }]
}
```

tmux 윈도우 탭 표시: `✻` = Claude 작업 중, `●N` = 안 보고 있는 윈도우에 알림 N개 (윈도우 진입 시 리셋).

## tmux-translate

copy-mode에서 `v`로 선택 후 `t` → Gemini 번역 팝업 (한↔영 자동 감지).
머신마다 API 키를 Keychain에 한 번 등록해야 한다:

```bash
security add-generic-password -a "$USER" -s "gemini-api-key" -w "YOUR_KEY"
```

## Restow (after changes)

```bash
cd ~/dotfiles
stow -R <package>
```
