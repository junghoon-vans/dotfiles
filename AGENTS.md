# PROJECT KNOWLEDGE BASE

macOS development environment repository. Applies chezmoi-managed config files to `$HOME`, installs Homebrew packages, bootstraps language runtimes, and applies optional macOS defaults through `setup.sh`.

## STRUCTURE

```text
dotfiles/
├── .chezmoiroot          # Points chezmoi at home/
├── home/                 # Chezmoi source state for dotfiles and .config payload
├── Brewfile              # Homebrew packages and harness tools
├── docs/                 # Split setup, tooling, overrides, examples, and troubleshooting docs
├── setup.sh              # Public setup entrypoint (execs setup/main.sh)
├── setup/
│   ├── main.sh           # Command orchestrator with flags and utility commands
│   ├── check.sh          # Repository validation utility command
│   ├── clean-backups.sh  # Managed dotfile backup cleanup utility command
│   ├── doctor.sh         # Host prerequisite inspection utility command
│   ├── link.sh           # Chezmoi apply wrapper with backup compatibility
│   ├── lib/common.sh     # Shared shell helpers, output, and prompts
│   ├── commands/*        # Default setup commands with ordered filenames
│   ├── languages/*.sh    # Runtime and language-specific tooling installers
│   ├── blockchain/*.sh   # Blockchain runtime and CLI tooling installers
│   └── apps/*.sh         # App/bootstrap helpers used by setup commands
└── tests/setup/          # Setup harness regression tests
```

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Shell config | `home/dot_zshrc` | Chezmoi source for `~/.zshrc` |
| App configs | `home/dot_config/*/` | Chezmoi source for per-app settings under `~/.config` |
| Install packages | `Brewfile` | Homebrew list |
| Setup automation | `setup.sh` / `setup/main.sh` | Public entrypoint + filename-driven orchestrator |
| Setup docs | `docs/setup.md` | Command flow, flags, utility commands |
| Tooling docs | `docs/tool-matrix.md` | LSP, formatter, linter, harness coverage |
| Apply dotfiles | `setup/link.sh` | Backs up differing targets, then applies chezmoi source state into `$HOME` |
| Karabiner setup | `setup/commands/55-karabiner` | Karabiner-Elements install and key remapping config |
| macOS settings | `setup/commands/60-macos` | Finder, Dock, screenshot, and appearance defaults |
| CI | `.github/workflows/ci.yml` | Mirrors repository validation checks |

## KEY DECISIONS

- **mise**: Owns runtime version selection for Go, Node, Python, Rust, Java, Kotlin, and Bun.
- **Node package management**: `./setup.sh node` enables Corepack and installs pnpm through the configured Node runtime.
- **zoxide**: Replaces autojump. `z` jumps by frecency; `j` is kept for muscle memory.
- **Shell aliases**: `.zshrc` is the source of truth for aliases like `ls`, `l`, `ll`, `la`, and `lt`.
- **delta**: Git diff pager with syntax highlighting, side-by-side view, and line numbers.
- **prek**: Replaces pre-commit with a faster Rust implementation.
- **Go 1.25**: Pinned in `mise.toml`; Go tooling is installed by `./setup.sh go`.
- **gnopls**: Built with the Go runtime selected by mise.
- **LemMinX**: Installed from the pinned Eclipse Maven uber JAR and exposed through `$HOME/.local/bin/lemminx`.
- **Solana/Anchor**: Solana CLI is installed with the upstream Anza Agave installer; Anchor is installed through AVM from `solana-foundation/anchor`; wrappers expose `solana`, `agave-install`, `cargo-build-sbf`, `avm`, and `anchor` through `$HOME/.local/bin`.
- **Blockchain setup**: `./setup.sh blockchain` owns Solana/Anchor and Gno tooling; they remain explicit commands but are not part of the language umbrella.
- **Biome LSP**: Explicitly mapped to JSON/JSONC only, avoiding overlap with TypeScript LSP and leaving CSS to Biome formatter/linter coverage.
- **Karabiner setup**: Separate from broader macOS defaults so `--skip karabiner` can exclude key remapping setup.
- **Utility commands**: `check`, `doctor`, and `clean-backups` are explicit-only commands, not part of full setup.
- **Secrets**: `gh/hosts.yml` and GitHub Copilot generated token files are never tracked.

## CONVENTIONS

- All paths use `$HOME` instead of specific usernames.
- `home/dot_config/` mirrors `~/.config/`; keep app config documentation in this root `AGENTS.md` or `docs/`, not in a root `.config/` tree.
- `setup.sh` flow is `bootstrap → brew-packages → languages → blockchain → links → apps → opencode → karabiner → macos`.
- Language commands (`go`, `node`, `bun`, `java`, `kotlin`, `xml`, `rust`, `python`, `typescript`) are explicit options; `languages` is the default language umbrella command.
- Blockchain commands (`solana`, `gno`) are explicit options; `blockchain` is the default blockchain umbrella command.
- `--skip` accepts default, utility, and language command names; utility commands are explicit-only and are not selected by full setup.
- `setup/link.sh` backs up files only when content differs from the chezmoi source version before applying.
- `clean-backups` removes only managed `*.backup.YYYYMMDD-HHMMSS` files whose current target still matches the chezmoi source.
- Language-specific LSPs, formatters, linters, and related CLIs are installed by their language commands.
- `set -euo pipefail` is active in all shell scripts; use `|| true` only for intentional optional commands.

## COMMANDS

```bash
./setup.sh                         # Full interactive setup
./setup.sh --yes                   # Full non-interactive setup
./setup.sh --dry-run               # Preview selected commands
./setup.sh --skip karabiner --yes  # Full setup except Karabiner key remapping setup
./setup.sh languages opencode      # Run specific default commands
./setup.sh blockchain              # Install Solana/Anchor and Gno tooling
./setup.sh solana                  # Install Solana CLI and Anchor tooling
./setup.sh check                   # Run repository checks
./setup.sh doctor                  # Inspect host setup state
./setup.sh clean-backups           # Remove managed dotfile backups
brew bundle --file Brewfile        # Install Brewfile packages
```

## NOTES

- Requires Homebrew for package installation.
- App config source lives under `home/dot_config/`: GitHub CLI preferences in `gh/config.yml`, Karabiner remapping in `karabiner/karabiner.json`, Neovim config in `nvim/`, OpenCode/OpenAgent config in `opencode/`, and Zed settings in `zed/settings.json`.
- `home/dot_config/nvim` is repo-owned and applied by chezmoi; setup no longer bootstraps LazyVim starter into `$HOME/.config/nvim`.
- OpenCode config uses the public config schema and `oh-my-openagent` plugin config.
- Java runtime provisioning is mise-owned by `./setup.sh java`; Kotlin runtime and language server provisioning is owned by `./setup.sh kotlin`.
- Solana CLI and Anchor are not mise-managed: `./setup.sh solana` installs Rust with mise, then uses the Anza Agave installer and AVM, with shell integration through `$HOME/.local/bin` wrappers.
