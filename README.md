# Dotfiles

Personal development environment configuration files for macOS, optimized for Go development and modern CLI tools.

## Overview

This repository contains my personal dotfiles for:
- **Zsh** configuration with Oh My Zsh
- **Git** configuration with useful aliases and color schemes
- **Global gitignore** for common temporary and system files

## Features

### Zsh Configuration
- **Theme**: [Spaceship](https://github.com/spaceship-prompt/spaceship-prompt) - Minimalist, powerful and customizable prompt
- **Plugins**: git, golang, docker, npm, node, nvm, vscode, brew, macos, sudo, web-search, jsontools, colored-man-pages, zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting
- **Modern CLI tools** with convenient aliases:
  - `bat` instead of `cat` (syntax highlighting)
  - `eza` instead of `ls` (better file listing with icons)
  - `rg` (ripgrep) instead of `grep` (faster search)
  - `fd` instead of `find` (faster file finding)
- **FZF** integration for fuzzy finding
- **Autojump** for quick directory navigation
- **NVM** for Node.js version management

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
  - `f` = find files in codebase
  - `la` = list all git aliases
- **Enhanced colors** for better readability
- **Merge/Diff tool**: vimdiff with diff3 conflict style

### Go Development
- Custom Go path configuration
- Go-specific aliases:
  - `gob` = go build
  - `gor` = go run
  - `got` = go test ./...
  - `gomt` = go mod tidy
  - `gomi` = go mod init
  - `gofmt` = go fmt ./...
  - `govet` = go vet ./...
- Linting aliases:
  - `lint` = golangci-lint run
  - `lintfix` = golangci-lint run --fix
- **Custom function**: `gonew <project-name>` - Creates a new Go project with module initialization and hello world template

### Global Gitignore
Comprehensive ignore patterns for:
- macOS system files (.DS_Store, etc.)
- IDEs (VSCode, JetBrains, Vim, Sublime)
- Go build artifacts
- Node.js dependencies
- Environment files and secrets
- Build and temporary files

## Installation

### Prerequisites

1. **Install Oh My Zsh**:
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

2. **Install modern CLI tools**:
   ```bash
   brew install bat eza ripgrep fd fzf autojump
   ```

3. **Install Neovim**:
   ```bash
   brew install neovim
   ```

### Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/junghoon-vans/dotfiles.git
   ```

2. Run the installation script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

   This will:
   - Backup any existing dotfiles (adds `.backup` extension)
   - Create symlinks from your home directory to the dotfiles

3. Install Oh My Zsh plugins:
   ```bash
   # Autosuggestions
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

   # Syntax highlighting
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

   # Completions
   git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
   ```

4. Install Spaceship theme:
   ```bash
   git clone https://github.com/spaceship-prompt/spaceship-prompt.git ~/.oh-my-zsh/custom/themes/spaceship-prompt --depth=1
   ln -s ~/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme
   ```

5. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

## Customization

### Update Git User Information

Edit `.gitconfig` and update the user section:
```ini
[user]
    name = Your Name
    email = your.email@example.com
```

### Add Custom Aliases

You can add your own aliases in `~/.zshrc` or create separate files in `$ZSH_CUSTOM/` (e.g., `~/.oh-my-zsh/custom/aliases.zsh`).

### Modify Zsh Theme

The current theme is Spaceship. To change it, edit the `ZSH_THEME` variable in `.zshrc`:
```bash
ZSH_THEME="your-theme-name"
```

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
- `gonew myproject` - Create new Go project
- `got` - Run all tests
- `lint` - Run linter
- `lintfix` - Run linter with auto-fix

## Files

- `.zshrc` - Zsh shell configuration
- `.gitconfig` - Git configuration
- `.gitignore_global` - Global gitignore patterns
- `install.sh` - Installation script for creating symlinks
