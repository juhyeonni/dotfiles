# nvim plugin classification

Every plugin the nvim config loads, sorted into used, unclear or unused for the rebuild
(LazyVim to `vim.pack`). Tracking: #16, Issue: #10. Nothing here changes the config.

## Criteria

The groups answer "does this plugin belong in the new config", not "is it used today".

- **Used**: a keymap, call site or tuned config justifies keeping it. `snacks.nvim` and `oil.nvim`
  are here by the picker and file explorer decision on #10.
- **Unclear**: the evidence is weak or conflicting. You decide in the rebuild Issues.
- **Unused**: disabled, duplicated, no call site, or dropped by a decision.

Evidence is read from the config (keymaps, `opts`, call sites), not measured by running nvim.
Sources: the specs under `nvim/.config/nvim/lua/plugins/`, `config/lazy.lua`, `config/keymaps.lua`,
LazyVim 16.0.1 (core plugins and the extras this config imports), and `lazy-lock.json`.

Origin values: `declared` (a spec in this repo), `LazyVim core`, `extra: <name>` (imported in
`config/lazy.lua`, or a LazyVim default extra), `planned` (not installed yet).

A dependency is not a row of its own. It goes with its parent and follows its verdict:
`plenary.nvim` (claude-code.nvim), `nui.nvim` (noice.nvim), `nvim-nio` (nvim-dap-ui),
`mason-lspconfig.nvim` (nvim-lspconfig), `friendly-snippets` (blink.cmp), `cmp-cmdline` (nvim-cmp).

## Summary

| Group | Plugins |
|---|---|
| Used | 37 |
| Unclear | 18 |
| Unused | 12 |

## Used

| Plugin | Origin | Evidence | Note |
|---|---|---|---|
| kanagawa.nvim | declared | `colorscheme = "kanagawa"` in `config/lazy.lua`; dragon theme and transparency in `colorscheme.lua` | |
| snacks.nvim | LazyVim core | dashboard header and `scroll` off in `ui.lua`; LazyVim calls `Snacks.rename` and others | Decision on #10: keeps the picker. Also the notifier overlap, see nvim-notify |
| oil.nvim | planned | Decision on #10: replaces neo-tree and telescope-file-browser | Not installed yet |
| nvim-treesitter | LazyVim core | `ensure_installed` list in `treesitter.lua` | |
| nvim-lspconfig | LazyVim core | servers, `LspAttach` keymaps (`gd`, `<leader>ca`) in `lsp.lua` | `gd` calls `telescope.builtin`, see the keymap section |
| mason.nvim | LazyVim core | `ensure_installed` tools in `lsp.lua` | |
| blink.cmp | extra: coding.blink | `<C-@>` shows the menu in `keymaps.lua`; `winblend` in `editor.lua` | Insert-mode completion. Also covers cmdline, see nvim-cmp |
| conform.nvim | extra: formatting.prettier | prettier extra imported in `config/lazy.lua` | No repo config of its own |
| rustaceanvim | extra: lang.rust | rust extra imported; `rust` in treesitter list | |
| crates.nvim | extra: lang.rust | same extra | |
| SchemaStore.nvim | extra: lang.json | json extra imported | |
| mini.hipatterns | extra: util.mini-hipatterns | `hsl_color` highlighter in `editor.lua` using `craftzdog/hsl.lua` | Declared and imported as an extra |
| flash.nvim | LazyVim core | `search` options in `editor.lua`; `keymaps.lua` comments rely on its `s` jump | |
| git.nvim | declared | `<Leader>gb` blame, `<Leader>go` browse | |
| gitsigns.nvim | LazyVim core | `on_attach` with `]h`, `[h`, `<leader>h*` keymaps | |
| diffview.nvim | declared | `<leader>gd`, `<leader>gh`, `<leader>gH` | |
| grug-far.nvim | LazyVim core | `<leader>sr` in `editor.lua` | |
| render-markdown.nvim | declared | long config in `editor.lua`; `autocmds.lua` sets `wrap` off for it | |
| claude-code.nvim | declared | `<C-\><C-\>` toggle; `util/claude_code_action.lua` and `<leader>ca` | `plenary.nvim` comes with it |
| noice.nvim | LazyVim core | routes, presets and commands in `ui.lua` | `nui.nvim` comes with it |
| bufferline.nvim | LazyVim core | `<Tab>` and `<S-Tab>` in `ui.lua`; `keymaps.lua` leaves them to it | |
| lualine.nvim | LazyVim core | `pretty_path` section in `ui.lua` | |
| zen-mode.nvim | declared | `<leader>z` | |
| neoscroll.nvim | declared | scroll keymaps for `<C-u>`, `<C-d>`, `zt` and others in `ui.lua` | |
| smear-cursor.nvim | declared | tuned `opts`; `neoscroll` config mentions it | No keymap, visual only |
| nvim-treesitter-context | declared | `<leader>ut` toggle and tuned `opts` | |
| dropbar.nvim | declared | `<leader>;` pick | `incline.nvim` was disabled in its favor |
| nvim-surround | declared | `ys`, `ds`, `cs` documented in `coding.lua` | |
| refactoring.nvim | declared | visual `<leader>r` | Normal-mode `<leader>r` is the hsl replace |
| mini.bracketed | declared | `setup` with per-target suffixes in `coding.lua` | |
| dial.nvim | declared | `<C-a>`, `<C-x>` and a custom augend group | |
| outline.nvim | declared | `<leader>cs` | |
| todo-comments.nvim | LazyVim core | `]t`, `[t` from LazyVim; pinned with `version = "*"` | No repo config beyond the version |
| vim-wakatime | declared | `lazy = false`; `~/.wakatime.cfg` exists | Time tracking, no keymap |
| which-key.nvim | LazyVim core | `desc` on repo keymaps; comments in `keymaps.lua` refer to its groups | |
| lazydev.nvim | LazyVim core | `lua_ls` is configured and this repo is mostly lua | |
| mini.icons | LazyVim core | icon provider for lualine, bufferline and snacks; no `nvim-web-devicons` installed | |

## Unclear

| Plugin | Origin | Evidence | Note |
|---|---|---|---|
| nvim-treesitter-textobjects | LazyVim core | no repo config or keymap | Depends on whether you use LazyVim's textobject keys |
| nvim-ts-autotag | LazyVim core | no repo config | Likely useful for html, svelte, astro (all in the treesitter list) |
| nvim-lint | LazyVim core | no `linters_by_ft` in this repo; `selene`, `luacheck`, `shellcheck` are installed through mason | The eslint extra uses the language server, not this plugin |
| nvim-dap | extra: dap.core | extra imported, no repo keymap or config | |
| nvim-dap-ui | extra: dap.core | same extra | `nvim-nio` comes with it |
| nvim-dap-virtual-text | extra: dap.core | same extra | |
| mason-nvim-dap.nvim | extra: dap.core | same extra | |
| img-clip.nvim | declared | `opts = {}` only, no keymap | |
| nvim-notify | declared | `opts` in `ui.lua`, used by noice | Overlaps `snacks.notifier`; `noice` keeps working with either |
| neogen | declared | `<leader>cc` | Sets `snippet_engine = "luasnip"` but LuaSnip is not installed (blink uses native snippets), so it may not work |
| inc-rename.nvim | declared | `cmd = "IncRename"`, no keymap; noice preset `inc_rename = false` | |
| markdown-preview.nvim | declared | `ft` and `cmd` only | render-markdown already renders in the buffer |
| rainbow-delimiters.nvim | declared | `version = "*"` only | |
| persistence.nvim | LazyVim core | no repo config | Session restore |
| trouble.nvim | LazyVim core | no repo config | LazyVim's `<leader>x` keys |
| mini.ai | LazyVim core | no repo config | |
| mini.pairs | LazyVim core | no repo config | |
| ts-comments.nvim | LazyVim core | no repo config | |

## Unused

| Plugin | Origin | Evidence | Note |
|---|---|---|---|
| telescope.nvim | declared | `;f`, `;r`, `\\`, `;t`, `;;`, `;e`, `;s`, `<leader>fP`, `<leader>fB` exist today | Keymap exists today, dropped by the picker decision on #10 |
| telescope-fzf-native.nvim | declared | loaded by the telescope config | Keymap exists today, dropped by the picker decision |
| telescope-file-browser.nvim | declared | `<leader>fB`, `hijack_netrw` | Keymap exists today, dropped by the picker decision; oil replaces it |
| neo-tree.nvim | extra: editor.neo-tree | `neotree.lua` shows dotfiles | Keymap exists today, dropped by the picker decision; oil replaces it |
| fzf-lua | extra: editor.fzf | not referenced in the repo; `install_version` 7 keeps the pre-8 defaults, which prefer fzf over snacks | LazyVim's own picker keys use it; snacks picker replaces it |
| nvim-cmp | declared | cmdline completion only, `event = "CmdLineEnter"` | Duplicate of blink.cmp, which completes the cmdline too. `cmp-cmdline` goes with it. Locked but not installed in the lazy dir |
| catppuccin | declared | `enabled = false` | Disabled; locked only |
| tokyonight.nvim | declared | `enabled = false` | Disabled; locked only |
| solarized-osaka.nvim | declared | `enabled = false` | Disabled; locked only |
| incline.nvim | declared | `enabled = false` | Duplicates dropbar. Locked only |
| lazy.nvim | LazyVim core | `config/lazy.lua` | Replaced by `vim.pack` in the rebuild |
| LazyVim | LazyVim core | `config/lazy.lua`, `lazyvim.json` | Dropped in the rebuild; its keymaps and defaults go with it |

## Keymaps needing a snacks equivalent

These call `telescope.builtin` or its file browser and must be rebuilt on the snacks picker or oil.

| Keymap | Today | Replace with |
|---|---|---|
| `gd` (in `lsp.lua`) | `telescope.builtin.lsp_definitions` | snacks picker LSP definitions |
| `;f` | `find_files` with hidden files | snacks picker files |
| `;r` | `live_grep` with `--hidden` | snacks picker grep |
| `\\` | `buffers` | snacks picker buffers |
| `;t` | `help_tags` | snacks picker help |
| `;;` | `resume` | snacks picker resume |
| `;e` | `diagnostics` | snacks picker diagnostics |
| `;s` | `treesitter` symbols | snacks picker treesitter or LSP symbols |
| `<leader>fP` | `find_files` in the plugin root | snacks picker files with `cwd` |
| `<leader>fB` | telescope file browser at the buffer's directory | oil at the buffer's directory |
