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
Interactive runs print each command description before asking for Y/n confirmation, so you can see what the step installs or changes before approving it. The `languages` and `blockchain` commands also ask before each nested subcommand.

## Default Commands

| Command | Purpose |
| --- | --- |
| `bootstrap` | Installs Homebrew if it is missing. |
| `brew-packages` | Installs common `Brewfile` dependencies, including Homebrew-managed `mise` and `chezmoi`, and performs brew-owned post-install steps. |
| `languages` | Installs selected language runtimes from `mise.toml` and language-specific tools by running `go`, `node`, `bun`, `java`, `kotlin`, `xml`, `rust`, `python`, and `typescript`. |
| `blockchain` | Installs selected blockchain tooling by running `solana` and `gno`. |
| `links` | Applies chezmoi-managed dotfiles from `home/` into `$HOME`. |
| `apps` | Installs Oh My Zsh and Zed Gno extension support. |
| `opencode` | Installs OpenCode and bootstraps oh-my-openagent. |
| `karabiner` | Installs Karabiner-Elements for key remapping and confirms the linked config path. |
| `macos` | Applies keyboard, Finder, Dock, screenshot, appearance, and related defaults. |

## Utility Commands

| Command | Purpose |
| --- | --- |
| `doctor` | Checks required host tools, Brewfile package state, harness tools, and core managed dotfiles. |
| `check` | Runs repository validation: shell syntax, optional shellcheck and actionlint, JSON parsing, Brewfile syntax, whitespace checks, and setup smoke tests. |
| `clean-backups` | Removes managed `*.backup.YYYYMMDD-HHMMSS` files created before chezmoi apply when the current target still matches the tracked source. |

## Language Commands

Language commands are explicit options as well as the building blocks of `languages`:

| Command | Purpose |
| --- | --- |
| `go` | Installs the configured Go runtime with mise, then `gopls`, `golangci-lint`, and `gofumpt` into `~/.local/bin`. |
| `node` | Installs the configured Node.js runtime with mise, then enables Corepack and installs pnpm. |
| `bun` | Installs the configured Bun runtime with mise. |
| `java` | Installs the configured Java runtime with mise, then `jdtls`. |
| `kotlin` | Installs the configured Kotlin runtime with mise, then `kotlin-language-server`. |
| `xml` | Installs the pinned Eclipse LemMinX JAR. |
| `rust` | Installs the configured Rust runtime with mise, then `rust-analyzer` and `cargo-nextest`. |
| `python` | Installs the configured Python runtime with mise, then `uv`, `pyright`, and `ruff`. |
| `typescript` | Installs TypeScript, TypeScript LSP, and Biome. |

## Blockchain Commands

Blockchain commands are explicit options as well as the building blocks of `blockchain`:

| Command | Purpose |
| --- | --- |
| `solana` | Installs the Solana CLI with the Anza Agave installer, exposes `cargo build-sbf`, then Anchor through AVM. |
| `gno` | Installs `gno` and `gnopls` into `~/.local/bin` using mise-managed Go. |

Examples:

```bash
./setup.sh go python
./setup.sh go bun typescript
./setup.sh blockchain
./setup.sh solana
./setup.sh --skip rust --yes
```

`gno`, `solana`, `xml`, and `typescript` install their required Go, Rust, Java, and Bun runtimes through mise before installing their tooling. Use `languages` and `blockchain` to install the full ordered sets, or run individual commands to install only selected environments.

`mise.toml` is the declarative runtime target for Go, Node, Python, Rust, Java, Kotlin, and Bun. `./setup.sh brew-packages` installs Homebrew-managed `mise`, while each language command runs `mise install <tool>` for its selected runtime before installing language-owned CLIs such as `gopls`, `pnpm`, `pyright`, `ruff`, `kotlin-language-server`, the LemMinX JAR, and Biome. OpenCode launches runtime-backed LSPs through `mise exec <tool@version> -- ...` without depending on a local dotfiles checkout path. Go-backed CLI installs use the mise-selected Go runtime and set `GOBIN=$HOME/.local/bin`, so future `mise exec -- go install ...` commands expose binaries without adding `$HOME/go/bin` to PATH. Blockchain commands live under `setup/blockchain/`: Gno tooling uses the configured Go runtime, while Solana CLI and Anchor are intentionally not tracked in `mise.toml`. `./setup.sh solana` uses the upstream Anza Agave installer for Solana CLI, exposes Solana's `cargo-build-sbf` binary so `cargo build-sbf` works from `~/.local/bin`, and installs AVM from the Anchor repository for Anchor CLI.

## Dotfile Apply Behavior

`setup/link.sh` applies chezmoi source state from `home/`. Existing files are backed up only when their content differs from the tracked source before `chezmoi apply` runs.

Use `./setup.sh clean-backups` to remove old managed backup files after confirming the applied dotfiles are working. The cleanup only removes backups for targets that still match the tracked chezmoi source.

The repository root does not need a `.config/` tree. Chezmoi-applied app config source lives under `home/dot_config/`, and repo-local app config notes live in `AGENTS.md` or `docs/`.
