# Dotfiles

Personal macOS dotfiles optimized for Go, Rust, Java, Kotlin, Python, Node.js, and modern CLI tooling.

## Overview

This repository manages:

- Zsh and Oh My Zsh configuration
- Git, Delta, and global ignore configuration
- Neovim, Zed, Karabiner-Elements, GitHub CLI, and OpenCode config under `.config/`
- Homebrew packages through `Brewfile`
- A command-based setup harness under `setup/`

## Quick Start

```bash
git clone https://github.com/junghoon-vans/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles
./setup.sh
```

For non-interactive setup:

```bash
./setup.sh --yes
./setup.sh --skip keyboard --yes
./setup.sh --skip macos --yes
```

Preview what would run without changing the machine:

```bash
./setup.sh --dry-run
./setup.sh --dry-run --skip keyboard
```

## Setup Commands

Default commands run in filename order from `setup/commands/`:

1. `bootstrap` - install Homebrew if needed
2. `brew-packages` - install `Brewfile` packages and brew-owned post-install steps
3. `languages` - install Go, Node.js, Bun, SDKMAN Java/Kotlin, Rust, and Python support
4. `tool-packages` - install global Go and Bun CLI tools
5. `links` - create symlinks for dotfiles and `.config/*`
6. `apps` - install Oh My Zsh, OpenCode/OpenAgent, and Zed Gno extension support
7. `keyboard` - apply keyboard defaults
8. `macos` - apply Finder, Dock, screenshot, and appearance defaults

Utility commands are explicit only and are not part of full setup:

```bash
./setup.sh doctor    # Inspect host prerequisites and symlink state
./setup.sh check     # Run repository validation checks
```

## Documentation

- [Setup guide](docs/setup.md)
- [Tool matrix](docs/tool-matrix.md)
- [Local overrides](docs/local-overrides.md)
- [Troubleshooting](docs/troubleshooting.md)

## Useful Commands

```bash
./setup.sh --help
./setup.sh languages tool-packages
./setup.sh links apps
./setup.sh check
./setup.sh doctor
brew bundle --file Brewfile
```

After setup, reload the shell:

```bash
source ~/.zshrc
```
