# dotfiles

> Korean version: [README.ko.md](README.ko.md).

A macOS dev environment. Ghostty is the terminal, herdr the multiplexer and nvim the editor, and
Claude Code and pi run in herdr panes. Managed with [chezmoi](https://www.chezmoi.io/).

## Setup

| Area | Tool | Config (under `home/`) | Docs |
|------|------|------------------------|------|
| Terminal | Ghostty | `dot_config/ghostty/config` | — |
| Multiplexer | herdr | `dot_config/herdr/` | [herdr](docs/herdr.md) |
| Shell | zsh + Oh My Zsh | `dot_zshrc`, `dot_config/zsh/rc.d/` | [zsh](docs/zsh.md) |
| Editor | nvim 0.12 (`vim.pack`) | `dot_config/nvim/` | [nvim](home/dot_config/nvim/README.md) |
| Input source | Karabiner + Hammerspoon | `dot_config/karabiner/`, `dot_hammerspoon/` | [input-source](docs/input-source.md) |
| Agents | Claude Code · pi | `dot_claude/` · pi is not managed | [claude](docs/claude-code.md) · [pi](docs/pi.md) |
| git | git | `dot_gitconfig.tmpl`, `dot_config/git/ignore` | — |
| Packages | Homebrew (mise on Intel) | `Brewfile`, `dot_config/mise/` | — |
| Browser | Vimium link hint CSS | `vimium/` (repo root, not deployed) | [vimium](docs/vimium.md) |
| Finder | `defaults write` | `run_onchange_after_macos-finder.sh.tmpl` | — |
| macOS | `defaults write` (keyboard, text input, Dock, trackpad) | `run_onchange_after_macos-defaults.sh.tmpl` | — |
| Launcher | Alfred 5 | `alfred/` (repo root, Alfred's sync folder), `run_after_alfred-sync-folder.sh.tmpl` | — |
| Windows | Magnet | `magnet/` (repo root, imported by `run_onchange_after_magnet-settings.sh.tmpl`) | — |

`.chezmoiroot` points chezmoi at `home/`, so only what lives there is deployed. `dot_` becomes a
leading `.`, and `executable_` sets the execute bit. `docs/` is English only.

## How it is used

- Each project gets its own herdr workspace. `alt+s` opens workspace-jump, which picks from open
  workspaces, recently opened ones, zoxide and ghq. The right pane shows that workspace's agents and
  what they are doing; `→` lists them and `enter` jumps to one.
- The sidebar shows each workspace's agent state (blocked · working · done · idle) and the task
  Claude is working on.
- Ghostty turns the macOS shortcuts `cmd+t` (new tab), `cmd+w` (close workspace) and `ctrl+tab`
  (next tab) into herdr prefix (`ctrl+a`) sequences.
- `caps lock` toggles the input source between Korean and English, `right option` between Korean
  and Japanese.
- zsh turns on only the runtimes that are installed. Each file in `rc.d/` does nothing when its
  target is missing.

## New machine

Sign in to the App Store first: the Brewfile installs Magnet with `mas`.

```bash
brew install chezmoi                       # Homebrew first: https://brew.sh
git clone https://github.com/juhyeonni/dotfiles.git ~/dotfiles
chezmoi init --source ~/dotfiles --apply
```

What chezmoi does not do, in order:

1. Clone Oh My Zsh and five zsh plugins ([commands](docs/zsh.md#install)).
2. Run `herdr integration install claude` (and `pi` if you use it). The installer adds a second
   SessionStart hook to `~/.claude/settings.json`; check `chezmoi diff` and revert it if it
   duplicates the existing one.
3. Open nvim once so its plugins install, then run `:MasonInstall …`
   ([list](home/dot_config/nvim/REQUIREMENTS.md)).
4. Grant Input Monitoring to Karabiner and Accessibility to Hammerspoon and Alfred (snippet
   expansion needs it).
5. Paste `vimium/link-hints.css` into Vimium's options page ([vimium](docs/vimium.md)).
6. Open Alfred once, then run `chezmoi apply` again. `run_after_alfred-sync-folder.sh` points
   Alfred's sync folder at `alfred/`; Alfred writes there directly, so chezmoi does not deploy it
   and changes land in the repo as you make them.

The MuxJK font that Ghostty uses comes from [juhyeonni/MuxJK](https://github.com/juhyeonni/MuxJK)
through `.chezmoiexternal.toml.tmpl`; bump the tag there to update it.

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

Magnet keeps its settings in `defaults`, not a file. After changing shortcuts in Magnet, export them
back into the repo:

```bash
defaults export com.crowdcafe.windowmagnet magnet/com.crowdcafe.windowmagnet.plist
plutil -convert xml1 magnet/com.crowdcafe.windowmagnet.plist
```
