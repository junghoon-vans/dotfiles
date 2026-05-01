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
- **Prompt**: Uses the [Spaceship](https://github.com/spaceship-prompt/spaceship-prompt) Oh My Zsh theme by default
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

You can also run specific setup commands:

```bash
./setup.sh bootstrap
./setup.sh brew-packages languages tool-packages
./setup.sh links apps
```

### What Gets Installed

The `setup.sh` script runs the following commands:

1. **bootstrap**
   - Installs Homebrew if it is missing
2. **brew-packages**
   - Installs packages from `Brewfile`
   - Applies brew-owned post-install steps such as FZF setup and `libpq` linking
3. **languages**
   - Installs Go runtime support used by your shell and tools
   - Installs NVM and Node.js LTS
   - Installs Bun runtime
   - Installs SDKMAN, Java 11/17/21, and Kotlin
   - Installs Rust via rustup (optional prompt)
   - Installs latest stable Python via `uv python install --default`
4. **tool-packages**
   - Installs global Go CLI tools from explicit shell installers
   - Installs global Bun CLI tools from explicit shell installers
5. **links**
   - Creates symlinks for tracked dotfiles and `.config/*`
6. **apps**
   - Installs Oh My Zsh, plugins, and Spaceship fallback theme
   - Bootstraps `oh-my-openagent`
   - Sets up the Zed Gno dev extension
7. **macos**
   - Applies macOS defaults for Finder, Dock, keyboard, screenshots, and appearance

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

### Modify Zsh Prompt

By default, `.zshrc` uses the Spaceship Oh My Zsh theme. To change the prompt behavior, edit the `ZSH_THEME` setting in `.zshrc`:
```bash
ZSH_THEME="your-theme-name"
```

### Neovim

This repo already tracks Neovim config in `.config/nvim`, so setup no longer bootstraps a LazyVim starter into `~/.config/nvim`. The `links` command is the source of truth for Neovim configuration on a new machine.

### Setup Internals

`./setup.sh` remains the public entrypoint, but the implementation now lives under `setup/`:

- `setup/main.sh` orchestrates commands
- `setup/commands/` contains ordered command files such as `10-bootstrap` and `40-links`
- `setup/languages/` contains runtime installers
- `setup/packages/` contains global CLI installers
- `setup/apps/` contains app/bootstrap scripts

There is no longer a root `./link.sh` command. Symlink creation is owned by `setup/link.sh` and invoked through the `links` command.

### Ghostty / cmux

This repo also tracks Ghostty-compatible terminal font settings in `.config/ghostty/config`.

`cmux` reads Ghostty config for fonts and colors, so the tracked Ghostty config keeps `FiraCode Nerd Font Mono` as the primary font for terminal icons and adds `D2Coding` as the Hangul fallback to improve Korean rendering.

### OpenCode / OpenAgent

This repo tracks user-level OpenCode and OpenAgent config under `.config/opencode/`.

- `oh-my-openagent` terminal notifications are provided by the plugin's built-in notification hook on macOS.
- The repo explicitly tracks that preference in `.config/opencode/oh-my-openagent.json` via `"notification": { "force_enable": true }`, so notification behavior syncs through dotfiles instead of relying on plugin defaults.
- Agent routing is tuned for quality, speed, and cost: high-impact agents/categories use GPT-5.5, while search, review, writing, and quick paths use GPT-5.4.
- Runtime fallback is enabled, and core GPT-5.5 agents (`sisyphus`, `hephaestus`, `oracle`) fall back to GPT-5.4 for rate-limit or provider failures.
- Browser automation is pinned to the Playwright provider, and built-in workflow skills (`git-master`, `playwright`, `review-work`, `ai-slop-remover`, `frontend-ui-ux`) are enabled globally.
- OpenCode MCPs include GitHub, Atlassian, and Context7. Context7 uses the public remote endpoint without committing API keys; set `CONTEXT7_API_KEY` separately if higher rate limits are needed.

### Customize Karabiner Mappings

Edit `.config/karabiner/karabiner.json` to customize keyboard mappings. Changes are automatically synced via symlink.

## Useful Commands

### Navigation
- `..` - Go up one directory
- `...` - Go up two directories
- `....` - Go up three directories
- `z <directory>` - Jump to frequently used directory (zoxide)
