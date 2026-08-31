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
│   ├── doctor.sh         # Host prerequisite inspection utility command
│   ├── clean-backups.sh  # Managed dotfile backup cleanup utility command
│   ├── codex-mcp.sh      # Shared Codex and Oh My Pi APM synchronization utility
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
| macOS shortcut slots | `setup/commands/56-macos-shortcuts` | Five neutral Quick Action hotkey slots backed by ignored local scripts |
| macOS settings | `setup/commands/60-macos` | Finder, Dock, screenshot, and appearance defaults |
| CI | `.github/workflows/ci.yml` | Mirrors repository validation checks |

## KEY DECISIONS

- **mise**: Owns runtime version selection for Go, Node, Python, Rust, Java, Kotlin, and Bun through both repo-local `mise.toml` and global `~/.config/mise/config.toml`.
- **Node package management**: `./setup.sh node` enables Corepack and installs pnpm through the configured Node runtime.
- **zoxide**: Replaces autojump. `z` jumps by frecency; `j` is kept for muscle memory.
- **Shell aliases**: `.zshrc` is the source of truth for aliases like `ls`, `l`, `ll`, `la`, and `lt`.
- **delta**: Git diff pager with syntax highlighting, side-by-side view, and line numbers.
- **prek**: Replaces pre-commit with a faster Rust implementation.
- **Go 1.25**: Pinned in `mise.toml` and mirrored to global mise config; Go tooling is installed with the mise-selected Go runtime and exposed from the runtime's bin directory, which mise injects as `GOBIN` (this env var takes precedence over the `go env -w GOBIN=$HOME/.local/bin` fallback from `configure_mise_go_bin`).
- **Gno tooling**: `gno` and `gnopls` are installed with the mise-selected Go runtime and exposed from the mise-injected `GOBIN` bin directory.
- **LemMinX**: Installed from the pinned Eclipse Maven uber JAR at `$HOME/.local/share/lemminx/lemminx.jar` and launched with mise-managed Java.
- **Solana/Anchor**: Solana CLI is installed with the upstream Anza Agave installer; Anchor is installed through AVM from `solana-foundation/anchor`; wrappers expose `solana`, `agave-install`, `cargo-build-sbf`, `avm`, and `anchor` through `$HOME/.local/bin`.
- **Sui**: Sui CLI and Move tooling are installed through `suiup`, default to testnet, and use `sui move` for Sui Move work. Local validator runs use `sui start --with-faucet --force-regenesis`; `sui-test-validator` is compatibility-only.
- **Blockchain setup**: `./setup.sh blockchain` owns Solana/Anchor, Gno, and Sui tooling; they remain explicit commands but are not part of the language umbrella.
- **Biome LSP**: Explicitly mapped to JSON/JSONC only, avoiding overlap with TypeScript LSP and leaving CSS to Biome formatter/linter coverage.
- **Karabiner setup**: Separate from broader macOS defaults so `--skip karabiner` can exclude key remapping setup.
- **Utility commands**: `check`, `doctor`, `clean-backups`, and `codex-mcp` are explicit-only commands, not part of full setup.
- **Secrets**: `gh/hosts.yml` and GitHub Copilot generated token files are never tracked. `~/.claude.json` (account/session/machine state) is never tracked either; only `~/.claude/settings.json` is chezmoi-managed.

## CONVENTIONS

- All paths use `$HOME` instead of specific usernames.
- `home/dot_config/` mirrors `~/.config/`; keep app config documentation in this root `AGENTS.md` or `docs/`, not in a root `.config/` tree.
- `setup.sh` flow is `bootstrap → brew-packages → languages → blockchain → links → apps → omp → codex → agent-skills → karabiner → macos-shortcuts → maintenance → macos`.
- Language commands (`go`, `node`, `bun`, `java`, `kotlin`, `xml`, `rust`, `python`, `typescript`) are explicit options; `languages` is the default language umbrella command.
- Blockchain commands (`solana`, `gno`, `sui`) are explicit options; `blockchain` is the default blockchain umbrella command.
- `--skip` accepts default, utility, language, and blockchain command names; utility commands are explicit-only and are not selected by full setup.
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
./setup.sh languages omp codex    # Run specific default commands
./setup.sh blockchain              # Install Solana/Anchor, Gno, and Sui tooling
./setup.sh solana                  # Install Solana CLI and Anchor tooling
./setup.sh sui                     # Install Sui CLI and Move tooling
./setup.sh codex                   # Install Codex CLI and LazyCodex
./setup.sh codex-mcp               # Reconfigure Codex MCP servers
./setup.sh agent-skills            # Synchronize shared global agent skills
./setup.sh maintenance             # Load weekly workstation maintenance agents
./setup.sh check                   # Run repository checks
./setup.sh doctor                  # Inspect host setup state
./setup.sh clean-backups           # Remove managed dotfile backups
brew bundle --file Brewfile        # Install Brewfile packages
```

## NOTES

- Requires Homebrew for package installation.
- App config source lives under `home/dot_config/`: GitHub CLI preferences in `gh/config.yml`, Karabiner remapping in `karabiner/karabiner.json`, Neovim config in `nvim/`, and Zed settings in `zed/settings.json`.
- `home/dot_config/nvim` is repo-owned and applied by chezmoi; setup no longer bootstraps LazyVim starter into `$HOME/.config/nvim`.
- Oh My Pi configuration lives in `home/dot_omp/agent/config.yml`; it discovers globally APM-installed skills from `~/.agents/skills` and shared MCP servers from APM-managed `~/.codex/config.toml`.
- Java runtime provisioning is mise-owned by `./setup.sh java`; Kotlin runtime and language server provisioning is owned by `./setup.sh kotlin`.
- Solana CLI and Anchor are not mise-managed: `./setup.sh solana` installs Rust with mise, then uses the Anza Agave installer and AVM, with shell integration through `$HOME/.local/bin` wrappers.
- Sui CLI is not Homebrew-managed: `./setup.sh sui` installs Rust with mise, then uses the official `suiup` installer, with shell integration through `$HOME/.local/bin`.
- **Codex CLI and LazyCodex**: `./setup.sh codex` installs `@openai/codex` globally via mise-managed npm, then runs `npx lazycodex-ai install --no-tui --codex-autonomous` to bootstrap LazyCodex (oh-my-openagent for Codex). Requires Node.js runtime.
- **Codex HUD**: `./setup.sh codex` installs `fwyc0573/codex-hud` into `$HOME/.local/share/codex-hud`, exposes `codex-hud*` management commands from `$HOME/.local/bin`, and the managed `.zshrc` routes `codex`/`codex-resume` through the HUD wrapper when installed. Requires `tmux` from the Brewfile.
- **Hermes Agent**: The Brewfile installs `hermes-agent` for CLI bootstrap on new machines. The Desktop app remains a separate `/Applications/Hermes.app` install, and an existing installer-managed `$HOME/.local/bin/hermes` can intentionally take PATH precedence over Homebrew's `/opt/homebrew/bin/hermes`. Do not track `~/.hermes/config.yaml`, `.env`, `auth.json`, sessions, profile state, memories, or gateway credentials.
- **Claude Code**: The Brewfile installs the `claude-code` cask for CLI bootstrap on new machines; an existing native-installer-managed `$HOME/.local/bin/claude` can intentionally take PATH precedence over Homebrew's cask binary. `home/dot_claude/settings.json` is chezmoi-managed and applied to `~/.claude/settings.json`. Do not track `~/.claude.json`, `~/.claude/history.jsonl`, `~/.claude/projects/`, `~/.claude/sessions/`, `~/.claude/shell-snapshots/`, or other account/session/machine state.
- **Gno MCP for Codex and Oh My Pi**: `./setup.sh codex` installs the configured `gnomcp` repo/ref into `$HOME/.local/bin` and registers the `gnomcp@gnoverse` Codex plugin. APM declares the shared `gnomcp` MCP server, alongside Atlassian, GitHub Copilot, Context7, Firecrawl, Aside-backed Playwright, and native Aside; it writes these to `~/.codex/config.toml`, which both Codex and Oh My Pi discover. Defaults track `gnoverse/gno-mcp@v0.11.0`; set `GNOMCP_REPO`, `GNOMCP_REF`, and `GNOMCP_RELEASE_VERSION` to override.
- **Codex default model**: `./setup.sh codex` idempotently sets `model` and `model_reasoning_effort` in `~/.codex/config.toml` via `ensure_codex_default_model` in `setup/apps/codex.sh`, defaulting to `gpt-5.6-luna` at `high` reasoning effort. Override with `CODEX_DEFAULT_MODEL` / `CODEX_DEFAULT_MODEL_REASONING_EFFORT` env vars. The rest of `config.toml` (project trust levels, hook trust hashes, plugin/marketplace state) stays untracked local/session state, same as `~/.claude.json`.
- **Shared agent packages**: `./setup.sh omp`, `./setup.sh codex`, `./setup.sh agent-skills`, and `./setup.sh codex-mcp` synchronize the APM manifest's global skills and MCP declarations. APM owns `~/.agents/skills` and its generated MCP entries; chezmoi must not manage those output paths.
