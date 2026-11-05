# dotfiles

> Korean version: [README.ko.md](README.ko.md).

A macOS dev environment. Ghostty is the terminal, herdr the multiplexer and nvim the editor, and
Claude Code and pi run in herdr panes. Managed with [chezmoi](https://www.chezmoi.io/).

## Setup

| Area | Tool | Config (under `home/`) | Docs |
|------|------|------------------------|------|
| Terminal | Ghostty | `dot_config/ghostty/config` | — |
| Multiplexer | herdr (instead of tmux) | `dot_config/herdr/` | [herdr](docs/herdr.md) |
| Shell | zsh + Oh My Zsh | `dot_zshrc`, `dot_config/zsh/rc.d/` | [zsh](docs/zsh.md) |
| Editor | nvim 0.12 (`vim.pack`) | `dot_config/nvim/` | [nvim](home/dot_config/nvim/README.md) |
| Input source | Karabiner + Hammerspoon | `dot_config/karabiner/`, `dot_hammerspoon/` | [input-source](docs/input-source.md) |
| Agents | Claude Code · pi | `dot_claude/` · pi is not managed | [claude](docs/claude-code.md) · [pi](docs/pi.md) |
| git | git | `dot_gitconfig.tmpl`, `dot_config/git/ignore` | — |
| Packages | Homebrew (mise on Intel) | `Brewfile`, `dot_config/mise/` | — |
| Browser | Vimium link hint CSS | `vimium/` (repo root, not deployed) | [vimium](docs/vimium.md) |

`.chezmoiroot` points chezmoi at `home/`, so only what lives there is deployed. `dot_` becomes a
leading `.`, and `executable_` sets the execute bit. `docs/` is English only.

## How it is used

- **One project, one herdr workspace.** `alt+s` opens workspace-jump: pick from open workspaces,
  recently opened ones, zoxide and ghq. The right pane shows that workspace's agents and what they
  are doing; `→` lists them and `enter` jumps to one.
- **The sidebar** shows each workspace's agent state (blocked · working · done · idle) and the task
  Claude is working on.
- **macOS shortcuts reach herdr.** Ghostty turns `cmd+t` (new tab), `cmd+w` (close workspace) and
  `ctrl+tab` (next tab) into herdr prefix (`ctrl+a`) sequences.
- **Input source**: `caps lock` toggles Korean ↔ English, `right option` Korean ↔ Japanese.
- **zsh** turns on only the runtimes that are installed. Each file in `rc.d/` does nothing when its
  target is missing.

## New machine

```bash
brew install chezmoi                       # Homebrew first: https://brew.sh
git clone https://github.com/juhyeonni/dotfiles.git ~/dotfiles
chezmoi init --source ~/dotfiles --apply   # asks for git name and email once, installs the Brewfile
```

What chezmoi does not do, in order:

1. **zsh** — clone Oh My Zsh and five plugins ([commands](docs/zsh.md#install)).
2. **herdr integration** — `herdr integration install claude` (and `pi` if you use it). The
   installer adds a second SessionStart hook to `~/.claude/settings.json`; check `chezmoi diff` and
   revert it if it duplicates the existing one.
3. **nvim** — plugins install on first launch. Run `:MasonInstall …` once
   ([list](home/dot_config/nvim/REQUIREMENTS.md)).
4. **Font** — install `MuxJK`, which Ghostty uses.
5. **Permissions** — Input Monitoring for Karabiner, Accessibility for Hammerspoon.
6. **Vimium** — paste `vimium/link-hints.css` into the options page ([vimium](docs/vimium.md)).

On Intel Macs the CLI tools come from [mise](https://mise.jdx.dev) instead of Homebrew; install
mise first. Language runtimes are installed when a project needs them.

## Day to day

```bash
chezmoi diff     # what differs between the repo and the home directory
chezmoi re-add   # pull edits made in the home directory back into the repo
chezmoi apply    # write the repo's state into the home directory
```

Files are copies, not links. After editing through the home path, run `chezmoi re-add`. This
matters most for files their own program rewrites: `karabiner.json` and Claude Code's
`settings.json`. Check `chezmoi diff` before `chezmoi apply`.
