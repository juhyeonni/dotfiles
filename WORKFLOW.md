# Dev workflow

Ties the scattered tools (ghq · sesh · tmux · LazyVim · lazygit · Claude Code) into a single loop.
Core rule: **one project = one tmux session = 3 windows (editor / agent / git)**.

## A. Entering a project (sesh-centric)

```bash
ghq get <owner>/<repo>     # clones into ~/.ghq/github.com/... (matches lazy's dev.path)
```

- `prefix + S` → the sesh session switcher (zoxide-backed fuzzy jump). Pick a project directory and
  `dev-layout.sh` sets up the **editor / agent / git** windows automatically.
- Reattaching does not duplicate windows, and nvim is not relaunched if it is already running.
- Pinned sessions go under `[[session]]` in `~/.config/sesh/sesh.toml`.

## B. Code loop (nvim ↔ Claude)

| Action                                     | Key                                                       |
| ------------------------------------------ | --------------------------------------------------------- |
| Send selection/file to Claude to ask or refactor | `<leader>ca` (n/v)                                   |
| Toggle the Claude Code window              | `<C-\><C-\>`                                              |
| Cycle / list diagnostics                   | `]d` `[d` · `;e` (telescope) · `<leader>Q` (loclist)      |
| Navigate code                              | `gd` (definition) · `<leader>cs` (outline) · `s` (flash jump) |
| Toggle inlay hints                         | `<leader>i`                                               |

The loop: write in nvim → when stuck, ask Claude with `<leader>ca` → clear the diagnostics → next.

## C. Commit and review loop (git)

- **Commit often, one change at a time.** Stage hunk by hunk in `prefix + G` (lazygit), then commit.
- Reviewing inside nvim: `<leader>hs`/`<leader>hp` (gitsigns hunk) · `<leader>gd` (diffview).
- Commit messages follow **conventional commits** (`feat:` `fix:` `docs:` `refactor:` `chore:`).
- Run **tests / build / lint** to verify before declaring anything done (global instruction).

## D. Locking it in with automation

- Pinning the test and build commands in a per-project `CLAUDE.md` lets Claude verify on its own.
- To enforce lint/format, add a git pre-commit hook (currently manual).

## Frequently used tmux keys

`prefix + g` scratch popup · `prefix + C-c` Claude popup · `prefix + G` lazygit ·
`prefix + S` sesh · `prefix + tab` extrakto · `C-h/j/k/l` move between nvim and tmux panes
