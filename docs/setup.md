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
./setup.sh --skip macos-shortcuts # Exclude macOS shortcut slot installation
```

`--skip` accepts default commands, utility commands, language commands, and blockchain commands, but utility commands are never selected unless passed explicitly.
Interactive runs print each command description before asking for Y/n confirmation, so you can see what the step installs or changes before approving it. The `languages` and `blockchain` commands also ask before each nested subcommand.

## Default Commands

| Command | Purpose |
| --- | --- |
| `bootstrap` | Installs Homebrew if it is missing. |
| `brew-packages` | Installs common `Brewfile` dependencies, including Homebrew-managed `mise`, `chezmoi`, and `hermes-agent`, and performs brew-owned post-install steps. |
| `languages` | Installs selected language runtimes from `mise.toml` and language-specific tools by running `go`, `node`, `bun`, `java`, `kotlin`, `xml`, `rust`, `python`, and `typescript`. |
| `blockchain` | Installs selected blockchain tooling by running `solana`, `gno`, and `sui`. |
| `links` | Applies chezmoi-managed dotfiles from `home/` into `$HOME`. |
| `apps` | Installs Oh My Zsh and Zed Gno extension support. |
| `codex` | Installs Codex CLI, bootstraps LazyCodex configuration, installs Codex HUD, installs the configured gnomcp repo/ref, registers the `gnomcp@gnoverse` Codex plugin, configures file-backed MCP OAuth storage, and ensures gnomcp, Atlassian, Firecrawl, Aside-backed Playwright, and native Aside MCP servers are registered. |
| `codex-agents` | Installs selected global Codex custom agents into `~/.codex/agents/`. |
| `karabiner` | Installs Karabiner-Elements for key remapping and confirms the linked config path. |
| `macos-shortcuts` | Installs five neutral macOS Quick Action shortcut slots backed by local ignored scripts. |
| `macos` | Applies keyboard, Finder, Dock, screenshot, appearance, and related defaults. |

## Utility Commands

| Command | Purpose |
| --- | --- |
| `doctor` | Checks required host tools, Brewfile package state, harness tools, and core managed dotfiles. |
| `check` | Runs repository validation: shell syntax, optional shellcheck and actionlint, JSON parsing, Brewfile syntax, whitespace checks, and setup smoke tests. |
| `codex-mcp` | Reconfigures Codex MCP servers without reinstalling Codex CLI or rerunning LazyCodex bootstrap. |
| `clean-backups` | Removes managed `*.backup.YYYYMMDD-HHMMSS` files created before chezmoi apply when the current target still matches the tracked source. |

## Language Commands

Language commands are explicit options as well as the building blocks of `languages`:

| Command | Purpose |
| --- | --- |
| `go` | Syncs the global mise runtime config, installs the configured Go runtime with mise, then `gopls`, `golangci-lint`, and `gofumpt` into `~/.local/bin`. |
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
| `gno` | Clones or updates `~/gno`, installs `gno` with `make install`, and installs `gnopls` using mise-managed Go. |
| `sui` | Installs the configured Rust runtime with mise, then installs `suiup`, Sui CLI, `move-analyzer` when supported, and the compatibility `sui-test-validator` wrapper. |

Examples:

```bash
./setup.sh go python
./setup.sh go bun typescript
./setup.sh blockchain
./setup.sh solana
./setup.sh sui
./setup.sh --skip rust --yes
```

`gno`, `solana`, `sui`, `xml`, and `typescript` install their required Go, Rust, Java, and Bun runtimes through mise before installing their tooling. Use `languages` and `blockchain` to install the full ordered sets, or run individual commands to install only selected environments.

`mise.toml` is the repository runtime target for Go, Node, Python, Rust, Java, Kotlin, and Bun. The matching chezmoi-managed `home/dot_config/mise/config.toml` is applied to `~/.config/mise/config.toml` as the global baseline, so those runtimes resolve from any directory after `.zshrc` activates mise. `./setup.sh bootstrap` also maintains a marked runtime block in `~/.zprofile` so login shells activate Homebrew first, then mise, and do not inherit stale `GOROOT` values. `./setup.sh brew-packages` installs Homebrew-managed `mise`, while each language command first syncs the global mise config and then runs `mise install <tool>` for its selected runtime before installing language-owned CLIs such as `gopls`, `pnpm`, `pyright`, `ruff`, `kotlin-language-server`, the LemMinX JAR, and Biome. Agent LSP commands launch runtime-backed tools through `mise exec <tool@version> -- ...` without depending on a local dotfiles checkout path. Go-backed CLI installs use the mise-selected Go runtime and set `GOBIN=$HOME/.local/bin`, so future `mise exec -- go install ...` commands expose binaries without adding `$HOME/go/bin` to PATH. Blockchain commands live under `setup/blockchain/`: Gno tooling uses the configured Go runtime, keeps the upstream checkout at `~/gno`, installs `gno` from that checkout with `make install`, and installs `gnopls` with Go; Solana CLI and Anchor are intentionally not tracked in `mise.toml`; Sui CLI and Move tooling are installed through `suiup` instead of Homebrew to avoid path and version conflicts. `./setup.sh solana` uses the upstream Anza Agave installer for Solana CLI, exposes Solana's `cargo-build-sbf` binary so `cargo build-sbf` works from `~/.local/bin`, and installs AVM from the Anchor repository for Anchor CLI. `./setup.sh sui` defaults to `SUI_VERSION=testnet`, uses `suiup install sui@testnet -y`, and installs `move-analyzer@testnet` when supported. Sui Move work is via `sui move`; local validator runs should use `sui start --with-faucet --force-regenesis`. The `sui-test-validator` wrapper remains compatibility-only and delegates to `sui start`.

## Dotfile Apply Behavior

`setup/link.sh` applies chezmoi source state from `home/`. Existing files are backed up only when their content differs from the tracked source before `chezmoi apply` runs.

Use `./setup.sh clean-backups` to remove old managed backup files after confirming the applied dotfiles are working. The cleanup only removes backups for targets that still match the tracked chezmoi source.

The repository root does not need a `.config/` tree. Chezmoi-applied app config source lives under `home/dot_config/`, and repo-local app config notes live in `AGENTS.md` or `docs/`.

## macOS Shortcut Slots

`./setup.sh macos-shortcuts` installs five neutral macOS Quick Actions named by key slot:

| Local script | Shortcut |
| --- | --- |
| `local/macos-shortcuts/1.sh` | `Ctrl+Cmd+Shift+1` |
| `local/macos-shortcuts/2.sh` | `Ctrl+Cmd+Shift+2` |
| `local/macos-shortcuts/5.sh` | `Ctrl+Cmd+Shift+5` |
| `local/macos-shortcuts/6.sh` | `Ctrl+Cmd+Shift+6` |
| `local/macos-shortcuts/7.sh` | `Ctrl+Cmd+Shift+7` |

Those `*.sh` files are ignored by Git. Setup symlinks each one into
`~/.local/share/dotfiles/macos-shortcuts/`, and the Automator workflows run the
symlink path. Editing an ignored local script changes the next shortcut run
without reinstalling the workflows.

To verify the installed workflows on macOS:

```bash
setup/apps/macos-shortcuts.sh check
```
