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
  - git, golang, docker, npm, node, nvm, vscode, brew, macos, sudo
  - web-search, jsontools, colored-man-pages
  - zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting
  - zsh-hangul - Auto Korean/English switching for better terminal experience
- **FZF** integration for fuzzy finding
- **Autojump** for quick directory navigation

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
- **Merge/Diff tool**: vimdiff with diff3 conflict style
- **GitHub Actions**: `act` for running workflows locally

### Development Environments

#### Go Development
- Custom Go path configuration
- Go-specific aliases: `gob`, `gor`, `got`, `gomt`, `gomi`, `gofmt`, `govet`
- Linting: `lint`, `lintfix` (golangci-lint)
- Debugging: `dlv` (delve debugger)
- Task runner: `task` (go-task)

#### Rust Development
- Cargo configuration via rustup
- Rust-specific aliases: `cb`, `cr`, `ct`, `cc`, `cclippy`, `cfmt`, `cupdate`

#### Java/Kotlin Development (via SDKMAN)
- Java 21 (Temurin)
- Kotlin (latest version)
- Managed through SDKMAN for easy version switching

#### Node.js Development
- NVM for Node.js version management
- Node.js LTS installed by default

### Modern CLI Tools
Aliases for enhanced command-line experience:
- `cat` → `bat` (syntax highlighting)
- `ls` → `eza` (better file listing with icons)
- `grep` → `rg` (ripgrep - faster search)

### Keyboard Customization
**Karabiner-Elements** configuration for macOS:
- `left_control + j/k/i/l` → Arrow keys (alternative mapping)

### AI Tools
- Claude Code CLI
- Cluade Squad
- Gemini CLI

### Global Gitignore
Comprehensive ignore patterns for:
- macOS system files (.DS_Store, etc.)
- IDEs (VSCode, JetBrains, Vim, Sublime)
- Go build artifacts
- Node.js dependencies
- Environment files and secrets
- Build and temporary files
- Claude Code project settings (.claude/settings.local.json)

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
   - Modern CLI tools: neovim, git, gh, lazygit, act, bat, eza, ripgrep, fd, htop, jq, tldr, fzf, autojump
   - AI tools: gemini-cli, claude-squad
   - Cloud tools: awscli
   - Container management: OrbStack
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
9. **Claude Code CLI** (via npm)
10. **SDKMAN**, Java 21, and Kotlin
11. **Rust** (optional - will prompt during setup)
12. **Symlinks** for all dotfiles

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

### Modify Zsh Theme

The current theme is Spaceship. To change it, edit the `ZSH_THEME` variable in `.zshrc`:
```bash
ZSH_THEME="your-theme-name"
```

### Customize Karabiner Mappings

Edit `.config/karabiner/karabiner.json` to customize keyboard mappings. Changes are automatically synced via symlink.

## Useful Commands

### Navigation
- `..` - Go up one directory
- `...` - Go up two directories
- `....` - Go up three directories
- `j <directory>` - Jump to frequently used directory (autojump)

### Git
- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git pull
- `glg` - git log with graph

### Go Development
- `got` - Run all tests
- `lint` - Run linter
- `lintfix` - Run linter with auto-fix

### Rust Development
- `cb` - Cargo build
- `cr` - Cargo run
- `ct` - Cargo test
- `cc` - Cargo check
- `cclippy` - Run clippy linter
- `cfmt` - Format code
