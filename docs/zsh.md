# zsh

zsh with [Oh My Zsh](https://ohmyz.sh/) and custom plugins. Config: `home/dot_zshrc`,
`home/dot_zprofile`, `home/dot_zshenv` and `home/dot_config/zsh/rc.d/`.

## Install

chezmoi does not install Oh My Zsh or its plugins. The shell starts without them but loses
completion and highlighting.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

ZC=~/.oh-my-zsh/custom/plugins
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions      $ZC/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting  $ZC/zsh-syntax-highlighting
git clone --depth 1 https://github.com/MichaelAquilina/zsh-you-should-use $ZC/you-should-use
git clone --depth 1 https://github.com/fdellwing/zsh-bat                  $ZC/zsh-bat
git clone --depth 1 https://github.com/Aloxaf/fzf-tab                     $ZC/fzf-tab
```

`git` and `fzf` ship with Oh My Zsh. `fzf-tab` loads after `zsh-autosuggestions` and before
`zsh-syntax-highlighting`. `ls` is `eza` when it is installed.

## Layers

| Layer | Location | Loaded |
|-------|----------|--------|
| Core | `.zshrc` | Always |
| Optional | `.config/zsh/rc.d/*.zsh` | In numeric order; each file checks for its own target |
| Machine-local | `~/.zshrc.local` | If it exists; never in the repo |
| Machine-local env | `~/.zshenv.local` (sourced by `.zshenv`) | Secrets every zsh needs, including non-interactive ones; never in the repo |

| `rc.d` file | Does |
|-------------|------|
| `05-herdr.zsh` | Clears tmux variables inherited inside herdr panes |
| `10-langs.zsh` | Language runtimes that are installed |
| `20-cloud.zsh` | Google Cloud SDK, if installed |
| `30-github.zsh` | Exports the GitHub token from the `gh` keyring for the GitHub MCP server |
| `40-claude.zsh` | `claude @name` runs Claude Code as another account ([accounts](claude-code.md#accounts)) |
| `90-sdkman.zsh` | SDKMAN, last because it prepends itself to `PATH` |

On a machine with no runtimes, every `rc.d` file does nothing. Install a runtime when a project
needs it; `.zshrc` does not change.
