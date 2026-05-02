# Setup Guide

`./setup.sh` is the public entrypoint. It delegates to `setup/main.sh`, which discovers ordered command files from `setup/commands/`.

## Modes

```bash
./setup.sh                 # Interactive full setup
./setup.sh --help          # Show commands with descriptions
./setup.sh --yes           # Non-interactive; answer yes to prompts
./setup.sh --no-input      # Non-interactive; use prompt defaults
./setup.sh --dry-run       # Print selected commands only
./setup.sh --skip karabiner # Exclude one command from a full setup
```

`--skip` accepts both default commands and utility commands, but utility commands are never selected unless passed explicitly.
Interactive runs print each command description before asking for Y/n confirmation, so you can see what the step installs or changes before approving it.

## Default Commands

| Command | Purpose |
| --- | --- |
| `bootstrap` | Installs Homebrew if it is missing. |
| `brew-packages` | Installs common `Brewfile` dependencies and brew-owned post-install steps. |
| `languages` | Installs all language runtimes by running `go`, `node`, `bun`, `java`, `rust`, and `python`. |
| `tool-packages` | Installs global Go and Bun CLI tools from explicit scripts. |
| `links` | Creates symlinks from this repo into `$HOME`. |
| `apps` | Installs Oh My Zsh, OpenCode/OpenAgent, and Zed Gno extension support. |
| `karabiner` | Installs Karabiner-Elements for key remapping and confirms the linked config path. |
| `macos` | Applies keyboard, Finder, Dock, screenshot, appearance, and related defaults. |

## Utility Commands

| Command | Purpose |
| --- | --- |
| `doctor` | Checks required host tools, Brewfile package state, harness tools, and core symlink targets. |
| `check` | Runs repository validation: shell syntax, optional shellcheck, JSON parsing, Brewfile syntax, whitespace checks, and setup smoke tests. |

## Language Commands

Language runtime commands are explicit options as well as the building blocks of `languages`:

| Command | Purpose |
| --- | --- |
| `go` | Installs `go@1.25` with Homebrew and activates it on `PATH`. |
| `node` | Installs NVM and Node.js LTS. |
| `bun` | Installs the Bun runtime. |
| `java` | Installs SDKMAN, Java 11/17/21, and Kotlin. |
| `rust` | Installs Rust with rustup. |
| `python` | Installs `uv` with Homebrew and installs the latest stable Python through `uv`. |

Examples:

```bash
./setup.sh go python
./setup.sh --skip rust --yes
```

## Symlink Behavior

`setup/link.sh` creates symlinks for root dotfiles and tracked `.config/*` files. Existing files are backed up only when their content differs from the repo version.

`.config/AGENTS.md` is intentionally skipped because it is repo-local agent knowledge, not user app configuration.
