# Dotfiles

Personal development environment configuration files for macOS, optimized for Go, Rust, Java, and Kotlin development with modern CLI tools.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
  - [Zsh Configuration](#zsh-configuration)
  - [Git Configuration](#git-configuration)
  - [Development Environments](#development-environments)
  - [Modern CLI Tools](#modern-cli-tools)
  - [Keyboard Customization](#keyboard-customization)
- [Installation](#installation)
  - [Automatic Setup (Recommended)](#automatic-setup-recommended)
- [What Gets Installed](#what-gets-installed)
- [Customization](#customization)
- [Useful Commands](#useful-commands)

## Overview

This repository contains my personal dotfiles for:
- **Zsh** configuration with Oh My Zsh
- **Git** configuration with useful aliases and color schemes
- **Global gitignore** for common temporary and system files
- **Neovim** with LazyVim
- **Karabiner-Elements** keyboard customization

## Features

### Zsh Configuration
- **Theme**: [Spaceship](https://github.com/spaceship-prompt/spaceship-prompt) - Minimalist, powerful and customizable prompt
- **Plugins**:
  - git, golang, docker, npm, node, brew, macos, sudo
  - web-search, jsontools, colored-man-pages
  - zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting
  - zsh-hangul - Auto Korean/English switching for better terminal experience
- **FZF** integration for fuzzy finding
- **Zoxide** for smart directory navigation

### Git Configuration
- User: Junghoon Ban (junghoon.ban@gmail.com)
- Default editor: `nvim`
- Default branch: `main`
- **Useful aliases**:
  - `co` = checkout
  - `br` = branch
  - `ci` = commit
  - `st` = status
  - `unstage` = reset HEAD --
  - `last` = log -1 HEAD
  - `visual` = graphical log view
  - `lg` = pretty formatted log with graph
- **Enhanced colors** for better readability
- **Delta** pager for syntax-highlighted, side-by-side diffs
- **Merge/Diff tool**: vimdiff with diff3 conflict style
- **GitHub Actions**: `act` for running workflows locally

### Development Environments

#### Go Development
- Custom Go path configuration

#### Rust Development
- Cargo configuration via rustup

#### Java/Kotlin Development (via SDKMAN)
- Java 11, 17, 21 (Temurin)
- Kotlin (latest version)
- Managed through SDKMAN for easy version switching

#### Node.js Development
- NVM for Node.js version management
- Node.js LTS installed by default

#### Python Development
- uv for Python installation and project/package management
- Latest stable Python installed via `uv python install --default`

### Modern CLI Tools
Aliases for enhanced command-line experience:
- `cat` → `bat` (syntax highlighting)
- `ls` → `eza` (better file listing with icons)
- `grep` → `rg` (ripgrep - faster search)
- `lg` → `lazygit` (terminal UI for git)

### Keyboard Customization
**Karabiner-Elements** configuration for macOS:
- `left_control + j/k/i/l` → Arrow keys (alternative mapping)
- `caps_lock` → `left_control`
- Korean input: Won sign(₩) → Backtick(`) - Inputs backtick instead of won sign when Korean input source is active

### AI Tools
- OpenCode

### Global Gitignore
Comprehensive ignore patterns for:
- macOS system files (.DS_Store, etc.)
- IDEs (VSCode, JetBrains, Vim, Sublime)
- Go build artifacts
- Node.js dependencies
- Environment files and secrets
- Build and temporary files

## Installation

### Automatic Setup (Recommended)

The easiest way to set up everything at once:

```bash
# Clone this repository
git clone https://github.com/junghoon-vans/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles

# Run the setup script (installs everything)
chmod +x setup.sh
./setup.sh
```

### What Gets Installed

The `setup.sh` script will automatically install and configure:

1. **Homebrew** (if not already installed)
2. **Homebrew packages** from Brewfile:
   - Modern CLI tools: neovim, git, git-delta, gh, lazygit, act, prek, bat, eza, ripgrep, fd, htop, jq, tldr, fzf, zoxide
   - LSP tools: marksman (Markdown language server)
   - Database clients: mysql-client, libpq
   - Cloud tools: awscli, grpcurl, terraform, terraform-ls
   - Container management: OrbStack
- Terminal emulator: Kaku (`tw93/tap/kakuku` cask)
   - Productivity: Ice (menu bar management)
   - Fonts: FiraCode Nerd Font (for terminal icons)
3. **Oh My Zsh** (shell framework)
4. **Oh My Zsh plugins**:
   - zsh-autosuggestions (command suggestions)
   - zsh-syntax-highlighting (syntax highlighting)
   - zsh-completions (additional completions)
   - zsh-hangul (Korean/English auto-switching)
5. **Spaceship theme** for Oh My Zsh
6. **FZF** fuzzy finder configuration
7. **LazyVim** for Neovim
8. **NVM** and Node.js LTS
9. **uv** and latest stable Python (`uv python install --default`)
10. **SDKMAN**, Java 11, 17, 21, and Kotlin
11. **Rust** (optional - will prompt during setup)
12. **Symlinks** for all dotfiles
13. **macOS defaults** (Finder, Dock, Keyboard, Screenshot)

After installation:
```bash
# Reload your shell configuration
source ~/.zshrc

# Or restart your terminal
```

## Customization

### Update Git User Information

The `.gitconfig` file includes support for local overrides. This allows you to keep personal settings separate from the shared configuration.

**Recommended approach:**
1. Copy the example file:
   ```bash
   cp ~/workspace/dotfiles/.gitconfig.override.example ~/.gitconfig.override
   ```

2. Edit `~/.gitconfig.override` with your personal settings:
   ```ini
   [user]
       name = Your Name
       email = your.email@example.com
   ```

This approach has several advantages:
- Your personal info is not tracked in git
- You can override any setting from `.gitconfig`
- You can use `includeIf` for directory-specific configs (e.g., different email for work projects)

**Alternative:** You can still edit `.gitconfig` directly, but the local override method is more flexible and keeps your personal data private.

### Add Custom Aliases

Add your own aliases in `~/.zshrc` or create separate files in `$ZSH_CUSTOM/` (e.g., `~/.oh-my-zsh/custom/aliases.zsh`).

### Machine-specific Overrides

Create `~/.zshrc.local` for settings that shouldn't be tracked (work proxies, machine-specific paths, etc.):

```bash
# ~/.zshrc.local - not tracked in git
export SOME_WORK_VAR=value
```

This file is automatically sourced at the end of `.zshrc` if it exists.

### Modify Zsh Theme

The current theme is Spaceship. To change it, edit the `ZSH_THEME` variable in `.zshrc`:
```bash
ZSH_THEME="your-theme-name"
```

### Kaku

Kaku is installed from `tw93/tap` via the `kakuku` cask:

```bash
brew install tw93/tap/kakuku
```

Kaku uses a WezTerm-compatible Lua config at `~/.config/kaku/kaku.lua`, so this repo tracks the terminal config in `.config/kaku/kaku.lua`.

Kaku also persists the active zoomed font size in `~/.config/kaku/.kaku_font_size`. That file is tracked in this repo as `.config/kaku/.kaku_font_size` so font-size changes can sync through the normal dotfiles symlink flow.

Kaku's shell integration under `~/.config/kaku/zsh/` and runtime state in `~/.config/kaku/state.json` are generated by Kaku and are not tracked in this repo. After installing or updating Kaku, run `kaku init` once inside the app to refresh the generated shell files.

### Customize Karabiner Mappings

Edit `.config/karabiner/karabiner.json` to customize keyboard mappings. Changes are automatically synced via symlink.

## Useful Commands

### Navigation
- `..` - Go up one directory
- `...` - Go up two directories
- `....` - Go up three directories
- `z <directory>` - Jump to frequently used directory (zoxide)
