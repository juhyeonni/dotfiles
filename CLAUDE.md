# dotfiles

Project instructions for this repo only. The user-scope instructions are a separate file —
`claude/.claude/CLAUDE.md`, symlinked to `~/.claude/CLAUDE.md` by stow.

## Rules

- **Write config file comments in English.** Why a key and why that value is this repo's real asset,
  but the comments themselves stay in English. The global instructions leave comment language to the
  repo, and this repo picks English — as it already does for commit messages and identifiers.
  Prose documents are English too; `README.ko.md` is the one Korean translation, kept in sync with
  `README.md` by hand.
- The `herdr` and `claude` packages use `stow -R --no-folding`. Links are created per file, so a file
  newly added to the repo does not exist until stow is run again.
- After editing `herdr/.config/herdr/config.toml`, run `herdr server reload-config`. herdr does not
  watch the file. Check syntax with `herdr config check`.
- stow only creates symlinks. Editing a linked file changes the repo immediately, so even when you
  edit through the home directory path, the thing being committed is the repo.
