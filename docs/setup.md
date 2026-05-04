# Setup Guide

`./setup.sh` is the public entrypoint for this macOS development environment. It delegates to `setup/main.sh`, which discovers ordered command files from `setup/commands/`.

This repository intentionally combines dotfiles, Homebrew package state, runtime intent, app setup, and host checks. The setup harness coordinates those layers rather than replacing the underlying tools.

## Modes

```bash
./setup.sh                 # Interactive full setup
./setup.sh --help          # Show commands with descriptions
./setup.sh --yes           # Non-interactive; answer yes to prompts
./setup.sh --no-input      # Non-interactive; use prompt defaults
./setup.sh --dry-run       # Print selected commands only
./setup.sh --skip karabiner # Exclude one command from a full setup
```

`--skip` accepts default commands, utility commands, and language commands, but utility commands are never selected unless passed explicitly.
Interactive runs print each command description before asking for Y/n confirmation, so you can see what the step installs or changes before approving it. The `languages` command also asks before each language subcommand.

## Default Commands

| Command | Purpose |
| --- | --- |
| `bootstrap` | Installs Homebrew if it is missing. |
| `brew-packages` | Installs common `Brewfile` dependencies and brew-owned post-install steps. |
| `languages` | Installs language runtimes and language-specific tools by running `go`, `node`, `bun`, `java`, `xml`, `rust`, `python`, `gno`, and `typescript`. `mise.toml` records the preferred runtime versions for tools mise can manage over time. |
| `links` | Creates symlinks from this repo into `$HOME`. |
| `apps` | Installs Oh My Zsh and Zed Gno extension support. |
| `opencode` | Installs OpenCode and bootstraps oh-my-openagent. |
| `karabiner` | Installs Karabiner-Elements for key remapping and confirms the linked config path. |
| `macos` | Applies keyboard, Finder, Dock, screenshot, appearance, and related defaults. |

## Utility Commands

| Command | Purpose |
| --- | --- |
| `doctor` | Checks required host tools, Brewfile package state, harness tools, and core symlink targets. |
| `check` | Runs repository validation: shell syntax, optional shellcheck and actionlint, JSON parsing, Brewfile syntax, whitespace checks, and setup smoke tests. |
| `clean-backups` | Removes managed `*.backup.YYYYMMDD-HHMMSS` files created by `links` when the current target is linked to this repo. |

## Language Commands

Language commands are explicit options as well as the building blocks of `languages`:

| Command | Purpose |
| --- | --- |
| `go` | Installs Go, `gopls`, `golangci-lint`, and `gofumpt`. |
| `node` | Installs NVM and Node.js LTS. |
| `bun` | Installs the Bun runtime. |
| `java` | Installs SDKMAN, Java 11/17/21, Kotlin, `jdtls`, and `kotlin-language-server`. |
| `xml` | Installs Eclipse LemMinX XML language server. |
| `rust` | Installs Rust with rustup, `rust-analyzer`, and `cargo-nextest`. |
| `python` | Installs `uv`, Python, `pyright`, and `ruff`. |
| `gno` | Installs `gno` and `gnopls` using Go. |
| `typescript` | Installs TypeScript, TypeScript LSP, and Biome. |

Examples:

```bash
./setup.sh go python
./setup.sh go gno bun typescript
./setup.sh --skip rust --yes
```

`gno` expects Go, `xml` expects Java, and `typescript` expects Bun to be available. Run the prerequisite language commands first on a clean host, or use `languages` to install the full ordered set.

`mise.toml` is the declarative runtime target for Go, Node, Python, Rust, Java, and Bun. The existing language scripts remain the compatibility layer for bootstrapping runtimes and installing language-owned CLIs such as `gopls`, `gnopls`, `pyright`, `ruff`, `lemminx`, and Biome.

## Symlink Behavior

`setup/link.sh` creates symlinks for root dotfiles and tracked `.config/*` files. Existing files are backed up only when their content differs from the repo version.

Use `./setup.sh clean-backups` to remove old managed backup files after confirming the linked dotfiles are working. The cleanup only removes backups for targets that currently symlink back to this repository.

`.config/AGENTS.md` is intentionally skipped because it is repo-local agent knowledge, not user app configuration.
