# PROJECT KNOWLEDGE BASE

**Generated:** 2026-03-09
**Commit:** 179257e
**Branch:** main

## OVERVIEW
macOS dotfiles management repository. Symlinks config files to $HOME, automated setup via setup.sh.

## STRUCTURE
```
dotfiles/
├── .config/              # App configs (zed, nvim, karabiner, opencode, kaku, gh)
│   ├── zed/settings.json
│   ├── nvim/             # Neovim config (LazyVim)
│   ├── karabiner/        # Keyboard remapping
│   ├── opencode/         # oh-my-opencode config
│   ├── gh/config.yml     # GitHub CLI config (excludes hosts.yml - contains tokens)
│   └── kaku/             # Terminal config
├── .zshrc               # Zsh shell config
├── .gitconfig           # Git config (delta pager, aliases)
├── .gitignore_global    # Global Git ignore
├── Brewfile             # Homebrew packages
├── setup.sh             # Public setup entrypoint (execs setup/main.sh)
├── setup/
│   ├── main.sh                          # Full setup orchestrator with explicit phases
│   ├── link.sh                          # Symlink implementation
│   ├── lib/common.sh                    # Shared shell helpers and output
│   ├── phases/10-bootstrap-homebrew.sh  # Homebrew bootstrap
│   ├── phases/20-install-brew-packages.sh# Brewfile install + brew-owned fixups
│   ├── phases/30-install-language-envs.sh# Language runtime orchestration
│   ├── phases/35-install-tool-packages.sh# Global CLI tool installation
│   ├── phases/40-link-dotfiles.sh       # Symlink phase
│   ├── phases/50-setup-apps.sh          # App/bootstrap phase
│   ├── phases/60-apply-macos.sh         # macOS defaults phase
│   ├── languages/*.sh                   # Go/Node/Bun/Java/Rust/Python runtime installers
│   ├── packages/*.sh                    # Global Go/Bun CLI installers
│   └── apps/*.sh                        # Oh My Zsh, OpenCode, Zed bootstrap
└── README.md
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Shell config | `.zshrc` | Main entry point |
| App configs | `.config/*/` | Per-app settings |
| Install packages | `Brewfile` | Homebrew list |
| Setup automation | `setup.sh` / `setup/main.sh` | Public entrypoint + full phase orchestrator |
| Global CLI tools | `setup/packages/*.sh` | Explicit shell installers for Go/Bun tools |
| Create symlinks | `setup/link.sh` | Links to $HOME, backs up only if content differs |
| macOS settings | `setup/phases/60-apply-macos.sh` | System defaults (Finder, Dock, Keyboard, Screenshot) |

## KEY DECISIONS
- **NVM**: Lazy-loaded in .zshrc (not via OMZ plugin) — avoids ~500ms startup penalty
- **zoxide**: Replaces autojump. `z` to jump, `j` aliased for muscle memory
- **Shell aliases**: `.zshrc` is the source of truth for aliases like `ls`, `l`, `ll`, `la`, and `lt`; Kaku-generated shell files may be sourced first, but alias policy belongs in `.zshrc`
- **delta**: git diff pager — syntax highlighting, side-by-side, line numbers
- **prek**: Replaces pre-commit (Rust reimplementation, faster)
- **go@1.25**: Pinned version via `go@1.25` formula + symlink to `/opt/homebrew/opt/go`
- **gnopls**: Built with `GOTOOLCHAIN=go1.24.10` (build constraint), runtime uses go@1.25
- **gh/hosts.yml**: NOT tracked (OAuth tokens) — gitignored via `.gitignore_global`
- **github-copilot/apps.json**: NOT tracked (OAuth tokens) — gitignored

## CONVENTIONS
- All paths use `$HOME` instead of specific username
- `.config/` mirrors `~/.config/`
- setup.sh is phase-based (bootstrap → brew-packages → languages → tool-packages → links → apps → macos)
- setup/link.sh backs up files only when content differs from dotfiles version
- Go and Bun global CLI tools are installed by explicit shell scripts under `setup/packages/`

## COMMANDS
```bash
./setup.sh          # Full setup (Homebrew, tools, Zsh, macOS defaults, etc.)
./setup.sh languages tool-packages # Run specific phases
brew bundle         # Install Brewfile packages
```

## NOTES
- Requires Homebrew
- setup/link.sh auto-discovers all `.config/*` files
- `.config/nvim` is repo-owned and linked; setup no longer bootstraps LazyVim starter into `$HOME/.config/nvim`
- opencode config uses dev schema for oh-my-opencode plugin
- `set -euo pipefail` is active in all scripts — use `|| true` for optional commands
- SDKMAN init sources with `set +u` guard (sdkman-init.sh uses ZSH_VERSION which is unbound in bash)
