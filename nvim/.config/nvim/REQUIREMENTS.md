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
| **git** | Plugin management (lazy.nvim) | ❌ Required |
| **make** | Building native extensions | ❌ Required |
| **gcc/clang** | C compiler for treesitter | ❌ Required |
| **node & npm** | LSP servers, markdown preview | ❌ Required |
| **ripgrep (rg)** | Fast file searching (Telescope) | ❌ Required |
| **fd** | Fast file finder (Telescope) | ❌ Recommended |

### Language Servers & Tools (Auto-installed)

These will be automatically installed by Mason when you first open Neovim:

- **Lua**: stylua, selene, luacheck
- **TypeScript/JavaScript**: ts_ls, eslint, prettier
- **CSS/Tailwind**: css-lsp, tailwindcss-language-server
- **Shell**: shellcheck, shfmt
- **Rust**: rust-analyzer (if needed)

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
nvim --version         # Should be 0.9.0 or higher
node --version         # Should be 16.x or higher
npm --version          # Should be 8.x or higher
rg --version           # Should be 13.x or higher
fd --version           # Should be 8.x or higher

# Test Neovim installation
nvim --headless "+Lazy! sync" +qa

# First time setup (this will install all plugins)
nvim
```

### First Launch Checklist

1. **Open Neovim**: Run `nvim`
2. **Plugin Installation**: Lazy.nvim will automatically install plugins (wait for completion)
3. **Mason Tools**: Run `:Mason` and verify tools are being installed
4. **Treesitter**: Run `:TSUpdate` to ensure all parsers are installed
5. **Health Check**: Run `:checkhealth` to verify everything is working

---

## Optional Dependencies

These are not required but enhance functionality:

### tmux (for Zen Mode integration)

**macOS**:
```bash
brew install tmux
```

**Ubuntu/Debian**:
```bash
sudo apt install tmux
```

**Fedora/RHEL**:
```bash
sudo dnf install tmux
```

**Arch Linux**:
```bash
sudo pacman -S tmux
```

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

### Issue: Treesitter compilation fails

**Solution**: Ensure you have a C compiler installed.

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
:MasonInstall stylua selene luacheck shellcheck shfmt typescript-language-server css-lsp tailwindcss-language-server
```

### Issue: Telescope live_grep not working

**Solution**: Install ripgrep (rg).

```bash
# Verify ripgrep is installed and in PATH
which rg
rg --version

# If not found, install using your package manager (see above)
```

### Issue: telescope-fzf-native fails to build

**Solution**: Install make and a C compiler.

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

Then rebuild the plugin:
```vim
:Lazy build telescope-fzf-native.nvim
```

### Issue: markdown-preview.nvim fails to build

**Solution**: Ensure Node.js and npm are installed.

```bash
# Verify Node.js installation
node --version
npm --version

# If installed, manually build the plugin
cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app
npm install

# Or rebuild from Neovim
:Lazy build markdown-preview.nvim
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

- **Neovim**: 0.9.0 or higher
- **Node.js**: 16.x or higher
- **Git**: 2.x or higher
- **RAM**: 2GB minimum, 4GB recommended
- **Disk Space**: ~500MB for plugins and tools

---

## Post-Installation

After installing all dependencies and opening Neovim for the first time:

1. **Wait for plugins to install** (Lazy.nvim will show progress)
2. **Run health check**: `:checkhealth`
3. **Install Mason tools**: `:Mason` (most will auto-install)
4. **Update Treesitter parsers**: `:TSUpdate`
5. **Restart Neovim** to ensure everything loads correctly

---

## Getting Help

If you encounter issues not covered here:

1. Run `:checkhealth` in Neovim for diagnostic information
2. Check plugin-specific help with `:help <plugin-name>`
3. Review logs: `~/.local/state/nvim/` (Unix) or `~/AppData/Local/nvim-data/` (Windows)
4. Check lazy.nvim logs: `:Lazy log`

---

**Last Updated**: 2025-01-11
