## Neovim Configuration

A plain `vim.pack` config for Neovim 0.12+, no distribution. `lua/plugins/init.lua` lists every
plugin in one place, and `nvim-pack-lock.json` pins their commits.

## Installation

### 1. Install Dependencies

**See [REQUIREMENTS.md](./REQUIREMENTS.md) for detailed installation instructions for your OS.**

### 2. Install Configuration

```bash
stow nvim   # from the dotfiles repo; links ~/.config/nvim
nvim        # plugins install on first start
```

### 3. First Launch

1. Wait for `vim.pack` to install all plugins
2. Run the `:MasonInstall` line from [REQUIREMENTS.md](./REQUIREMENTS.md)
3. Run `:checkhealth` to verify setup
4. Restart Neovim

Per-machine settings go in `lua/plugins/local.lua` (git-ignored, optional).
