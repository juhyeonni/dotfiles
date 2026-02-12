# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Config |
|---------|--------|
| zsh | `.zshrc`, `.zprofile` |
| nvim | `.config/nvim/` (LazyVim) |
| tmux | `.config/tmux/tmux.conf` |
| wezterm | `.config/wezterm/` |
| git | `.gitconfig`, `.config/git/ignore` |
| karabiner | `.config/karabiner/karabiner.json` |

## Setup

```bash
brew install stow
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
stow zsh nvim tmux wezterm git karabiner
```

## Restow (after changes)

```bash
cd ~/dotfiles
stow -R <package>
```
