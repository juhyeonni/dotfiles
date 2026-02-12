## Neovim Configurations

Lazyvim + Craftzdog Configurations

## Installation

### 1. Install Dependencies

Before setting up this configuration, install required system dependencies:

**See [REQUIREMENTS.md](./REQUIREMENTS.md) for detailed installation instructions for your OS.**

Quick check:
```bash
# Verify you have these installed:
git --version
nvim --version
node --version
rg --version
fd --version
```

### 2. Install Configuration

```bash
# Backup existing config (if any)
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this configuration
git clone <your-repo-url> ~/.config/nvim

# Start Neovim (plugins will auto-install)
nvim
```

### 3. First Launch

1. Wait for Lazy.nvim to install all plugins
2. Run `:checkhealth` to verify setup
3. Run `:Mason` to check tool installation
4. Restart Neovim

For troubleshooting, see [REQUIREMENTS.md](./REQUIREMENTS.md#troubleshooting)
