# Neovim Configuration Requirements

This document lists all system dependencies required for this Neovim configuration.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation by OS](#installation-by-os)
  - [macOS](#macos)
  - [Ubuntu/Debian](#ubuntudebian)
  - [Fedora/RHEL/CentOS](#fedorарhelcentos)
  - [Arch Linux](#arch-linux)
  - [Windows](#windows)
- [Verification](#verification)
- [Optional Dependencies](#optional-dependencies)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Essential Dependencies

| Tool | Purpose | Auto-installed by Mason? |
|------|---------|--------------------------|
| **neovim 0.12+** | `vim.pack` plugin manager | ❌ Required |
| **git** | Plugin management (`vim.pack`) | ❌ Required |
| **gcc/clang** | C compiler for treesitter parsers | ❌ Required |
| **tree-sitter-cli** | Builds treesitter parsers (`brew install tree-sitter-cli`) | ❌ Required |
| **node & npm** | LSP servers installed by Mason | ❌ Required |
| **ripgrep (rg)** | Fast file searching (snacks picker grep) | ❌ Required |
| **fd** | Fast file finder (snacks picker files) | ❌ Recommended |

### Language Servers & Tools (installed by hand, once)

Mason does not install these on its own. Run this inside Neovim once:

```vim
:MasonInstall lua-language-server stylua selene luacheck shellcheck shfmt prettier vtsls eslint-lsp css-lsp html-lsp json-lsp yaml-language-server tailwindcss-language-server marksman
```

rust-analyzer comes from `rustup component add rust-analyzer`, and rustaceanvim starts it.

---

## Installation by OS

### macOS

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essential dependencies
brew install git neovim node ripgrep fd

# Verify installation
git --version
nvim --version
node --version
npm --version
rg --version
fd --version
```

**Note**: macOS comes with Clang, so no separate compiler installation needed.

---

### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install essential dependencies
sudo apt install -y git build-essential curl

# Install Neovim (latest stable)
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update
sudo apt install -y neovim

# Install Node.js (using NodeSource)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install ripgrep and fd
sudo apt install -y ripgrep fd-find

# Create symlink for fd (Debian/Ubuntu names it fd-find)
sudo ln -s $(which fdfind) /usr/local/bin/fd

# Verify installation
git --version
nvim --version
node --version
npm --version
rg --version
fd --version
```

---

### Fedora/RHEL/CentOS

```bash
# Install essential dependencies
sudo dnf install -y git gcc make curl

# Install Neovim
sudo dnf install -y neovim

# Install Node.js
sudo dnf install -y nodejs npm

# Install ripgrep and fd
sudo dnf install -y ripgrep fd-find

# Verify installation
git --version
nvim --version
node --version
npm --version
rg --version
fd --version
```

---

### Arch Linux

```bash
# Update system
sudo pacman -Syu

# Install essential dependencies
sudo pacman -S git base-devel neovim nodejs npm ripgrep fd

# Verify installation
git --version
nvim --version
node --version
npm --version
rg --version
fd --version
```

---

### Windows

#### Option 1: Using Scoop (Recommended)

```powershell
# Install Scoop if not already installed
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# Install essential dependencies
scoop install git neovim nodejs ripgrep fd gcc

# Verify installation
git --version
nvim --version
node --version
npm --version
rg --version
fd --version
```

#### Option 2: Using Chocolatey

```powershell
# Install Chocolatey if not already installed (run as Administrator)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install essential dependencies
choco install git neovim nodejs ripgrep fd mingw

# Verify installation
git --version
nvim --version
node --version
npm --version
rg --version
fd --version
```

#### Option 3: Manual Installation

1. **Git**: https://git-scm.com/download/win
2. **Neovim**: https://github.com/neovim/neovim/releases
3. **Node.js**: https://nodejs.org/
4. **Ripgrep**: https://github.com/BurntSushi/ripgrep/releases
5. **fd**: https://github.com/sharkdp/fd/releases
6. **MinGW-w64** (for gcc): https://www.mingw-w64.org/downloads/

---

## Verification

After installing dependencies, verify everything is working:

```bash
# Check versions
git --version          # Should be 2.x or higher
nvim --version         # Should be 0.12.0 or higher
node --version         # Should be 16.x or higher
npm --version          # Should be 8.x or higher
rg --version           # Should be 13.x or higher
fd --version           # Should be 8.x or higher

# First time setup (this will install all plugins)
nvim
```

### First Launch Checklist

1. **Open Neovim**: Run `nvim`
2. **Plugin Installation**: `vim.pack` installs the plugins on first start (wait for completion)
3. **Mason Tools**: Run the `:MasonInstall` line from above
4. **Treesitter**: With `tree-sitter-cli` on PATH, restart Neovim and the parsers install on their own
5. **Health Check**: Run `:checkhealth` to verify everything is working

---

## Optional Dependencies

These are not required but enhance functionality:

### WakaTime CLI (for time tracking)

```bash
# Install via pip
pip install wakatime

# Or via npm
npm install -g wakatime
```

### Better clipboard support (Linux)

**Ubuntu/Debian**:
```bash
sudo apt install xclip  # for X11
# or
sudo apt install wl-clipboard  # for Wayland
```

---

## Troubleshooting

### Issue: Treesitter parsers do not install

**Solution**: Install `tree-sitter-cli` (`brew install tree-sitter-cli`) and make sure a C compiler is installed.

**macOS**:
```bash
xcode-select --install
```

**Linux**:
```bash
# Ubuntu/Debian
sudo apt install build-essential

# Fedora/RHEL
sudo dnf groupinstall "Development Tools"

# Arch
sudo pacman -S base-devel
```

### Issue: Mason fails to install tools

**Solution**: Check network connectivity and npm configuration.

```bash
# Clear npm cache
npm cache clean --force

# Update npm
npm install -g npm@latest

# Inside Neovim, clean and reinstall
:MasonUninstallAll
:MasonInstall stylua selene luacheck shellcheck shfmt vtsls css-lsp tailwindcss-language-server
```

### Issue: Live grep not working

**Solution**: Install ripgrep (rg); the snacks picker grep needs it.

```bash
# Verify ripgrep is installed and in PATH
which rg
rg --version

# If not found, install using your package manager (see above)
```

### Issue: Clipboard not working on Linux

**Solution**: Install clipboard utility.

**X11**:
```bash
sudo apt install xclip
```

**Wayland**:
```bash
sudo apt install wl-clipboard
```

Then verify in Neovim:
```vim
:checkhealth clipboard
```

### Issue: Slow startup time

**Solution**: Profile startup and optimize.

```bash
# Profile startup
nvim --startuptime startup.log

# Check which plugins are slow
cat startup.log | sort -k2 -n | tail -20
```

Consider lazy-loading plugins or disabling unused features.

---

## Minimum System Requirements

- **Neovim**: 0.12.0 or higher
- **Node.js**: 16.x or higher
- **Git**: 2.x or higher
- **RAM**: 2GB minimum, 4GB recommended
- **Disk Space**: ~500MB for plugins and tools

---

## Post-Installation

After installing all dependencies and opening Neovim for the first time:

1. **Wait for plugins to install** (`vim.pack` shows progress)
2. **Run health check**: `:checkhealth`
3. **Install Mason tools**: the `:MasonInstall` line from above
4. **Update plugins**: `:lua vim.pack.update()`
5. **Restart Neovim** to ensure everything loads correctly

---

## Getting Help

If you encounter issues not covered here:

1. Run `:checkhealth` in Neovim for diagnostic information
2. Check plugin-specific help with `:help <plugin-name>`
3. Review logs: `~/.local/state/nvim/` (Unix) or `~/AppData/Local/nvim-data/` (Windows)

---

**Last Updated**: 2026-11-05
