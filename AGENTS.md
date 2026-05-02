# PROJECT KNOWLEDGE BASE

macOS dotfiles management repository. Symlinks config files to `$HOME`, installs Homebrew packages, bootstraps language runtimes, and applies optional macOS defaults through `setup.sh`.

## STRUCTURE

```text
dotfiles/
├── .config/              # App configs (zed, nvim, karabiner, opencode, gh)
├── .zshrc                # Zsh shell config
├── .gitconfig            # Git config (delta pager, aliases, local include)
├── .gitignore_global     # Global Git ignore
├── Brewfile              # Homebrew packages and harness tools
├── docs/                 # Split setup, tooling, overrides, and troubleshooting docs
├── setup.sh              # Public setup entrypoint (execs setup/main.sh)
├── setup/
│   ├── main.sh           # Command orchestrator with flags and utility commands
│   ├── check.sh          # Repository validation utility command
│   ├── doctor.sh         # Host prerequisite inspection utility command
│   ├── link.sh           # Symlink implementation
│   ├── lib/common.sh     # Shared shell helpers, output, and prompts
│   ├── commands/*        # Default setup commands with ordered filenames
│   ├── languages/*.sh    # Go/Node/Bun/Java/Rust/Python runtime installers
│   ├── packages/*.sh     # Global Go/Bun CLI installers
│   └── apps/*.sh         # Oh My Zsh, OpenCode, Zed bootstrap
└── tests/setup/          # Setup harness regression tests
```

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Shell config | `.zshrc` | Main entry point |
| App configs | `.config/*/` | Per-app settings |
| Install packages | `Brewfile` | Homebrew list |
| Setup automation | `setup.sh` / `setup/main.sh` | Public entrypoint + filename-driven orchestrator |
| Setup docs | `docs/setup.md` | Command flow, flags, utility commands |
| Tooling docs | `docs/tool-matrix.md` | LSP, formatter, linter, harness coverage |
| Global CLI tools | `setup/packages/*.sh` | Explicit shell installers for Go/Bun tools |
| Create symlinks | `setup/link.sh` | Links to `$HOME`, backs up only if content differs |
| Keyboard settings | `setup/commands/55-keyboard` | Key repeat and text substitution defaults |
| macOS settings | `setup/commands/60-macos` | Finder, Dock, screenshot, and appearance defaults |
| CI | `.github/workflows/ci.yml` | Mirrors repository validation checks |

## KEY DECISIONS

- **NVM**: Lazy-loaded in `.zshrc` (not via OMZ plugin) to avoid startup penalty.
- **zoxide**: Replaces autojump. `z` jumps by frecency; `j` is kept for muscle memory.
- **Shell aliases**: `.zshrc` is the source of truth for aliases like `ls`, `l`, `ll`, `la`, and `lt`.
- **delta**: Git diff pager with syntax highlighting, side-by-side view, and line numbers.
- **prek**: Replaces pre-commit with a faster Rust implementation.
- **go@1.25**: Pinned Homebrew formula with symlink to `/opt/homebrew/opt/go`.
- **gnopls**: Built with the active `go@1.25` toolchain.
- **Biome LSP**: Explicitly mapped to JSON/JSONC only, avoiding overlap with TypeScript LSP and leaving CSS to Biome formatter/linter coverage.
- **Keyboard defaults**: Separate from broader macOS defaults so `--skip keyboard` can exclude them.
- **Utility commands**: `check` and `doctor` are explicit-only commands, not part of full setup.
- **Repo-local AGENTS files**: `.config/AGENTS.md` is skipped by `setup/link.sh` and should not be linked into `$HOME/.config`.
- **Secrets**: `gh/hosts.yml` and GitHub Copilot generated token files are never tracked.

## CONVENTIONS

- All paths use `$HOME` instead of specific usernames.
- `.config/` mirrors `~/.config/` except repo-local knowledge files such as `.config/AGENTS.md`.
- `setup.sh` flow is `bootstrap → brew-packages → languages → tool-packages → links → apps → keyboard → macos`.
- `setup/link.sh` backs up files only when content differs from the dotfiles version.
- Go and Bun global CLI tools are installed by explicit shell scripts under `setup/packages/`.
- `set -euo pipefail` is active in all shell scripts; use `|| true` only for intentional optional commands.

## COMMANDS

```bash
./setup.sh                         # Full interactive setup
./setup.sh --yes                   # Full non-interactive setup
./setup.sh --dry-run               # Preview selected commands
./setup.sh --skip keyboard --yes   # Full setup except keyboard defaults
./setup.sh languages tool-packages # Run specific default commands
./setup.sh check                   # Run repository checks
./setup.sh doctor                  # Inspect host setup state
brew bundle --file Brewfile        # Install Brewfile packages
```

## NOTES

- Requires Homebrew for package installation.
- `.config/nvim` is repo-owned and linked; setup no longer bootstraps LazyVim starter into `$HOME/.config/nvim`.
- OpenCode config uses the public config schema and `oh-my-openagent` plugin config.
- SDKMAN init sources with a `set +u` guard because `sdkman-init.sh` may reference shell-specific unbound variables.
