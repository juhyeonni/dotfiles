# dotfiles

> Korean version: [README.ko.md](README.ko.md).

A macOS dev environment that treats agents as first-class citizens of the terminal. Claude Code and
pi live in panes, and their state shows up in the sidebar. Managed with
[GNU Stow](https://www.gnu.org/software/stow/).

Every config carries **why it is the way it is** — the attempts that were reverted, the traps that
were stepped on, the numbers that were measured.

## Key choices

Four places where this diverges from the usual dotfiles.

- **[herdr](#herdr) replaces tmux.** It is a multiplexer that surfaces whether an agent is blocked
  or working in the sidebar. Session restore is built in, so tmux-resurrect is unnecessary.
- **[Input source switching](#input-source-switching-karabiner--hammerspoon) is split across two
  programs.** Karabiner alone was tried and failed — that record, with source links, is kept rather
  than deleted.
- **[The zsh config is layered](#zsh).** On a new machine with no runtimes installed, the whole of
  `rc.d` is a no-op. `.zshrc` never needs touching.
- **[`~/.claude` is stowed selectively](#claude).** Over 500M of generated data lives in the same
  directory as the config, so what to leave out is harder than what to put in.

## Packages

| Package | Config |
|---------|--------|
| zsh | `.zshrc`, `.zprofile`, `.config/zsh/rc.d/` (optional layer) |
| nvim | `.config/nvim/` (LazyVim) |
| herdr | `.config/herdr/config.toml`, `.config/herdr/scripts/` |
| ghostty | `.config/ghostty/config` |
| git | `.gitconfig`, `.config/git/ignore` |
| karabiner | `.config/karabiner/karabiner.json` (key remapping) |
| hammerspoon | `.hammerspoon/init.lua` (input source switching) |
| claude | `.claude/` — CLAUDE.md (user scope), `settings.json`, statusline, `skills/` |
| vimium | `link-hints.css` (not stowed — see [below](#vimium)) |

## Bootstrap

```bash
# 1. Homebrew dependencies
brew install stow herdr neovim jq fzf fd ripgrep bat eza lazygit zoxide ghq

# 2. Clone & stow
git clone https://github.com/juhyeonni/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh nvim git ghostty karabiner hammerspoon
stow --no-folding herdr claude   # both keep generated data beside the config — folding drags it into the repo
```

The `tmux` and `sesh` packages are the pre-herdr setup. They are no longer stowed and are kept only
as a rollback path — to go back, run `brew install tmux sesh && stow tmux sesh` and switch the
auto-attach in `.zshrc` back to tmux.

stow only creates symlinks. Extra per-program installs (plugins and so on) are covered in the
sections below. The dev loop (enter project → code → commit) is in [WORKFLOW.md](WORKFLOW.md).

**Language runtimes (Rust, Node, Deno, Bun, JVM, gcloud) are not part of this.** The bootstrap sets
up shell, editor and terminal only; runtimes get installed when a project needs them
(see [the zsh section](#zsh)).

---

## zsh

Uses [Oh My Zsh](https://ohmyz.sh/) plus custom plugins. stow does not install them, so clone them
separately (the shell starts without errors if they are all missing, but loses completion and
highlighting).

```bash
# Oh My Zsh itself
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# custom plugins (ZSH_CUSTOM = ~/.oh-my-zsh/custom)
ZC=~/.oh-my-zsh/custom/plugins
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions      $ZC/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting  $ZC/zsh-syntax-highlighting
git clone --depth 1 https://github.com/MichaelAquilina/zsh-you-should-use $ZC/you-should-use
git clone --depth 1 https://github.com/fdellwing/zsh-bat                  $ZC/zsh-bat
git clone --depth 1 https://github.com/Aloxaf/fzf-tab                     $ZC/fzf-tab
```

- `git` and `fzf` ship with OMZ, so no clone is needed (`fzf` is in the brew list).
- Load order: `fzf-tab` must come after `zsh-autosuggestions` and before `zsh-syntax-highlighting`
  (see the comment in `.zshrc`).
- `ls` is aliased to `eza` (in the brew list). Without it, it falls back to plain `ls`.

### Layering

`.zshrc` (the core) handles only the shell itself; anything that may or may not exist was moved out.

| Layer | Location | Load condition |
|------|------|-----------|
| Core | `.zshrc` | Always |
| Optional (language runtimes, ...) | `.config/zsh/rc.d/*.zsh` | If the file exists, in numeric order. Each file guards itself |
| Machine-local | `~/.zshrc.local` | If it exists. Never enters the repo |

Each `rc.d` fragment only does something when its target is installed — with no `~/.sdkman`, for
instance, `90-sdkman.zsh` is a no-op end to end. **On a new machine with zero runtimes installed,
all of rc.d does nothing.** Install a runtime when you start using it; `.zshrc` stays untouched.

Startup time, measured: ~190ms total — oh-my-zsh 130ms, SDKMAN + gcloud 40ms, and roughly 10ms for
everything else combined.

## nvim

Based on [LazyVim](https://www.lazyvim.org/). On first launch, lazy.nvim installs the plugins
according to `lazy-lock.json`.

```bash
# align ghq root with nvim lazy's dev.path (~/.ghq/github.com)
git config --global ghq.root '~/.ghq'
```

See `.config/nvim/REQUIREMENTS.md` for the remaining requirements.

## herdr

[herdr](https://herdr.dev) — an agent-aware terminal multiplexer. It replaces tmux. The hierarchy is
**workspace (= project) > tab > pane**.

- The prefix is `ctrl+a` (carried over from tmux). Ghostty's `cmd+t` / `ctrl+tab` /
  `ctrl+shift+tab` hit that prefix via `\x01` sequences.

| Key | Action |
|---|---|
| `prefix+v` · `prefix+s`/`prefix+minus` | Split pane. `prefix+s` is kept from tmux — settings got pushed to `prefix+comma` |
| `prefix+shift+v` · `prefix+alt+v` | Break a pane into a new tab · join it into another tab (tmux's break/join-pane) |
| `prefix+hjkl` | Move between panes (herdr's defaults already match tmux) |
| `prefix+1..9` · `prefix+ctrl+h/l` · `ctrl+alt+h/l` | Tabs. herdr has no `bind -r`, so a prefix-less combo is kept alongside for repeat presses |
| `prefix+shift+1..9` · `prefix+shift+j/k` | Workspaces |
| `prefix+alt+1..9` · `prefix+alt+j/k` | Agents |

Modifiers pick the target — **shift = workspace, alt = agent**. herdr ships every workspace/agent
switching binding empty, so these were filled in by hand. The reasoning is in the
[config.toml](herdr/.config/herdr/config.toml) comments.

- `prefix+S` — the project entry point. Pick a zoxide candidate in fzf and it opens or creates the
  workspace. Duplicates are detected via the `ws_root` metadata token (the original absolute path)
  stamped at creation. It also opens on `alt+s` / `ctrl+alt+s`.
  `switch_ascii_input_source_in_prefix` only switches to ASCII *inside* prefix mode, so it cannot
  cover `alt+s`, which never goes through the prefix — Hammerspoon's `forceEnglishKeys` handles the
  Korean IME case instead.
- `prefix+alt+g` lazygit · `prefix+ctrl+c` Claude · `prefix+alt+t` scratch shell (all popups)
- `prefix+o` — jump to the pane that raised a notification. **Clicking the notification only
  activates the terminal app; it does not take you to the pane.**
- Surfacing agent state (blocked/working/done/idle) in the sidebar requires installing the hook:

```bash
herdr integration install claude
herdr config check                  # validate config.toml syntax
herdr server reload-config          # re-apply config to the running server (it does not watch the file)
```

Installed via brew, brew manages the version; with the standalone installer from herdr.dev,
`herdr update` updates itself (this machine uses the latter — `~/.local/bin/herdr`).

Session restore is built in (no tmux-resurrect/continuum). The layout survives a server restart, and
`[session] resume_agents_on_restore` brings agent conversations back too.

### pi integration

[pi](https://pi.dev) is another agent herdr recognizes. It attaches as a **pi extension** rather than
a hook.

```bash
herdr integration install pi        # ~/.pi/agent/extensions/herdr-agent-state.ts
herdr --skill > ~/.pi/agent/skills/herdr/SKILL.md   # lets pi drive herdr
```

Both files are generated, so neither enters the repo — regenerate them after a herdr update. Check
versions with `herdr integration status`.

With the skill installed, a pi instance inside a pane can create other panes and start agents through
the herdr CLI. The skill's description limits it to "only when the user explicitly mentions herdr",
so it stays out of the way otherwise.

**Confirmed** (measured with `herdr agent start smoke --kind pi`):

- Starting pi in a pane via `agent start --kind pi` gets it recognized as `pi`, and herdr tracks it
  **down to the session JSONL path**
- `agent prompt --wait` returns at completion (not on timeout)
- `agent read --source visible` reads the screen contents verbatim

**What does not work**: the `blocked` state never appears for pi. By design pi has no permission
popup, so there is no approval UI for herdr to detect. Even when asked a question it prints text and
goes `idle`. Detecting an approval wait would require a separate extension that provides a question
UI.

## ghostty

The terminal emulator. The key bindings that forward macOS habits into herdr live here — `cmd+t` →
`\x01c` (new tab), `ctrl+tab` → `\x01n`, `cmd+w` → `\x01D`, all translated into herdr prefix
sequences. `shift+enter` is sent as `\x1b\x0d` so newlines work inside agents.

**Font**: `MuxJK` — must be installed separately.

## git

`.gitconfig` (global settings) and `.config/git/ignore` (global gitignore). No extra dependencies.

## Input source switching (karabiner + hammerspoon)

Korean/English/Japanese switching is **split across two programs.** Karabiner turns a physical key
into a signal, and Hammerspoon interprets that signal as an input source switch.

| Key | Karabiner mapping | Hammerspoon action |
|----|----------------|------------------|
| `caps lock` | → `f19` | Korean ↔ English |
| `right option` | → `f17` | Korean ↔ Japanese |
| `shift+cmd+space` | — | Korean ↔ Japanese |

The `caps_lock → f19` mapping exists **both at the profile top level and inside the per-keyboard
entries under `devices[]`**. Deleting one leaves the other working — check both when changing it.

### Record of a Karabiner-only setup that was reverted

Dropping Hammerspoon and switching directly with Karabiner's `select_input_source` was tried and did
not work reliably, so it was reverted. That API uses a deprecated macOS Carbon API, and both the
official docs and the issue tracker report it being unstable for CJK input sources that carry an
`input_mode_id`, such as Korean and Japanese. Do not repeat the attempt.

- [to.select_input_source](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/select-input-source/) — explicitly notes possible CJK failure
- [Issue #1602](https://github.com/pqrs-org/Karabiner-Elements/issues/1602) — CJKV switching issues

### Worth knowing

- Karabiner needs Input Monitoring, Hammerspoon needs Accessibility permission (both granted
  manually).
- One keyboard is excluded in `devices[]` with `ignore: true` (vendor 1133 / product 49312). No
  Karabiner rule applies on that keyboard.

## pi

[pi](https://pi.dev) — a minimalist coding agent. Its config is `~/.pi/agent/settings.json`.
**Not stowed** — credentials (`auth.json`) and sessions live in the same directory.

```json
{ "defaultTools": ["read","bash","edit","write","grep","find","ls"] }
```

Always set `defaultTools`. pi enables **only four** tools by default — `read bash edit write` — and
`grep`/`find`/`ls` are built in but off. Left off, the model works around them through `bash` and
burns more tokens. (Verify with `pi -p "list your tools"`.)

Two things to watch:

- **An unauthenticated `defaultProvider`/`defaultModel` falls back silently.** Do not assume it is
  running the model in the config; check with `pi auth check --provider <name>`.
- The pi package cannot carry `AGENTS.md`. A package holds only four things — `extensions/`,
  `skills/`, `prompts/`, `themes/` — so global rules go directly in `~/.pi/agent/AGENTS.md`.

For wiring it to herdr, see [pi integration](#pi-integration) in the herdr section.

## claude

Instructions split across two scopes. **user** is `claude/.claude/CLAUDE.md` → stow →
`~/.claude/CLAUDE.md` (applies to every project); **project** is [CLAUDE.md](CLAUDE.md) at the repo
root (this repo only). Project loads later, so it wins any conflict.

`~/.claude` **mixes authored files and generated ones in a single directory** — over 500M of it is
generated, so what to exclude is the hard part.

| Included | Excluded |
|---|---|
| `CLAUDE.md`, `settings.json` | `~/.claude.json` — OAuth token (**outside** the directory) |
| `skills/clear-draft` | `projects/` — conversation transcripts. File contents and command output are stored in plaintext |
| `statusline-command.sh`, `subagent-statusline.sh` | `plugins/` — reinstalled from the list in `settings.json` |
| | `hooks/herdr-agent-state.sh` — generated by herdr (same reason as the pi extension) |
| | `history.jsonl`, `file-history/`, `shell-snapshots/` and other caches |

```bash
stow --no-folding claude          # folding drags 391M of projects/ into the repo
herdr integration install claude  # the SessionStart hook in settings.json points at this
```

**Order matters** — the hook script is generated by herdr, so it is not in the repo. Install it first
or the hook points at a missing path; Claude Code only warns and starts normally either way.

Some entries under `~/.claude/skills/` are symlinks into `~/.agents/skills/` — a separate tool
manages those, and this package leaves them alone.

## vimium

Link hint styling for [Vimium](https://github.com/philc/vimium) on Brave. **Not a stow target** —
Vimium settings live in the browser profile's `chrome.storage.sync` (LevelDB) rather than in a file,
so there is nothing to symlink.

```
Vimium options page → paste vimium/link-hints.css into "CSS for link hints" → Save
```

Because it is a manual copy-paste, it **flows both ways**. Edit it in the options page and you must
paste it back into the repo file, or the repo silently goes stale.

Key mappings, search engines and exclusion rules are not kept here. The `Download backup` button at
the bottom of the options page emits only the non-default values as key-sorted JSON, so all of it
could be version-controlled — but CSS is the only part being touched, so CSS is all that is kept.

---

## Restow (after changes)

```bash
cd ~/dotfiles
stow -R <package>
stow -R --no-folding herdr claude   # never fold these two — omitting the flag drags generated data in
```

For `herdr` and `claude` the target is a real directory, so links are created **per file**. That
means adding a new file to the repo does not create a link automatically — `stow -R` has to be run
again. Skip it and only that file is silently missing (which looks like a popup dying instantly with
`exit 127`).
