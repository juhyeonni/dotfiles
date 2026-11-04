# dotfiles

Project instructions for this repo only. The user-scope instructions are a separate file —
`home/dot_claude/CLAUDE.md`, deployed to `~/.claude/CLAUDE.md` by chezmoi.

## Rules

- **Write config file comments in English.** Why a key and why that value is this repo's real asset,
  but the comments themselves stay in English. The global instructions leave comment language to the
  repo, and this repo picks English — as it already does for commit messages and identifiers.
  Prose documents are English too; `README.ko.md` is the one Korean translation, kept in sync with
  `README.md` by hand.
- The source state lives under `home/` (`.chezmoiroot`), named by chezmoi's rules: `dot_` for a
  leading `.`, `executable_` for the execute bit. A file newly added there reaches the home
  directory on the next `chezmoi apply`.
- After editing `home/dot_config/herdr/config.toml`, run `chezmoi apply` and then
  `herdr server reload-config`. herdr does not watch the file. Check syntax with
  `herdr config check`.
- chezmoi deploys copies, not links. Editing a deployed file through the home directory path does
  not change the repo, so run `chezmoi re-add` afterwards and commit the result. Run `chezmoi diff`
  before `chezmoi apply` so that a newer edit in the home directory is not overwritten.
