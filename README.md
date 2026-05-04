# Anvil Dev Environment

Personal macOS development environment specification optimized for Go, Gno, Rust, Java, Kotlin, Python, Node.js, OpenCode, and modern CLI tooling.

## Overview

This repository manages:

- Chezmoi-managed dotfiles for Zsh, Git, Delta, global ignore configuration, and `.config` app settings under `home/`
- Homebrew packages through `Brewfile`
- Language runtime provisioning through Homebrew-managed `mise` and `mise.toml`
- macOS defaults and app-specific bootstrap scripts under `setup/`
- A command-based setup harness under `setup/`

The repository is intentionally broader than a dotfiles store: it is the source of truth for recreating a personal macOS workstation. Dotfiles are managed through chezmoi source state in `home/`, while Homebrew, mise, and setup scripts cover packages, runtimes, app setup, and host verification.

## Quick Start

```bash
git clone https://github.com/junghoon-vans/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles
./setup.sh
```

For non-interactive setup:

```bash
./setup.sh --yes
./setup.sh --skip karabiner --yes
./setup.sh --skip macos --yes
```

Preview what would run without changing the machine:

```bash
./setup.sh --help
./setup.sh --dry-run
./setup.sh --dry-run --skip karabiner
```

## Setup Commands

Default commands run in filename order from `setup/commands/`:

1. `bootstrap` - install Homebrew if needed
2. `brew-packages` - install common `Brewfile` packages, run `mise install`, and perform brew-owned post-install steps
3. `languages` - install language runtimes and language-specific tools
4. `links` - apply chezmoi-managed dotfiles and `.config/*`
5. `apps` - install Oh My Zsh and Zed Gno extension support
6. `opencode` - install OpenCode and bootstrap OpenAgent
7. `karabiner` - install Karabiner-Elements for key remapping
8. `macos` - apply keyboard, Finder, Dock, screenshot, and appearance defaults

Utility commands are explicit only and are not part of full setup:

```bash
./setup.sh doctor    # Inspect host prerequisites and managed dotfile state
./setup.sh check     # Run repository validation checks
./setup.sh clean-backups # Remove managed dotfile backups created by links
```

## Documentation

- [Setup guide](docs/setup.md)
- [Architecture notes](docs/architecture.md)
- [Tool matrix](docs/tool-matrix.md)
- [Local overrides](docs/local-overrides.md)
- [Troubleshooting](docs/troubleshooting.md)

## Useful Commands

```bash
./setup.sh --help
./setup.sh go python
./setup.sh languages opencode
./setup.sh links apps
./setup.sh check
./setup.sh doctor
./setup.sh clean-backups
brew bundle --file Brewfile
mise install # also run by ./setup.sh brew-packages
```

After setup, reload the shell:

```bash
source ~/.zshrc
```
