# PROJECT KNOWLEDGE BASE

**Generated:** 2026-03-09
**Commit:** 179257e
**Branch:** main

## OVERVIEW
macOS dotfiles management repository. Symlinks config files to $HOME, automated setup via setup.sh.

## STRUCTURE
```
dotfiles/
├── .config/              # App configs (zed, nvim, karabiner, opencode, ghostty, gh)
│   ├── zed/settings.json
│   ├── nvim/             # Neovim config (LazyVim)
│   ├── karabiner/        # Keyboard remapping
│   ├── opencode/         # oh-my-opencode config
│   ├── gh/config.yml     # GitHub CLI config (excludes hosts.yml - contains tokens)
│   └── ghostty/          # Terminal config
├── .zshrc               # Zsh shell config
├── .gitconfig           # Git config (delta pager, aliases)
├── .gitignore_global    # Global Git ignore
├── Brewfile             # Homebrew packages
├── Gofile               # Go global tools (go install)
├── Bunfile              # Bun global packages
├── setup.sh             # Full setup script (runs scripts/NN-*.sh in order)
├── link.sh              # Symlink creator
├── scripts/             # Modular setup steps
│   ├── 00-core.sh       # Common functions and colors
│   ├── 01-brew.sh       # Homebrew install
│   ├── 02-bundle.sh     # brew bundle
│   ├── 03-go.sh         # Go tools from Gofile
│   ├── 04-ohmyzsh.sh    # Oh My Zsh + plugins
│   ├── 05-fzf.sh        # FZF setup
│   ├── 06-nvim.sh       # LazyVim
│   ├── 07-node.sh       # NVM + Node.js
│   ├── 08-bun.sh        # Bun + Bunfile packages
│   ├── 09-java.sh       # SDKMAN + Java + Kotlin
│   ├── 10-rust.sh       # Rust via rustup
│   ├── 11-links.sh      # Symlinks via link.sh
│   ├── 12-zed.sh        # Zed extensions
│   └── 13-macos.sh      # macOS defaults
└── README.md
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Shell config | `.zshrc` | Main entry point |
| App configs | `.config/*/` | Per-app settings |
| Install packages | `Brewfile` | Homebrew list |
| Go tools | `Gofile` | `go install` packages, supports GOTOOLCHAIN= per line |
| Bun packages | `Bunfile` | Global bun packages |
| Setup automation | `setup.sh` | Full install script, auto-discovers scripts/NN-*.sh |
| Create symlinks | `link.sh` | Links to $HOME, backs up only if content differs |
| macOS settings | `scripts/13-macos.sh` | System defaults (Finder, Dock, Keyboard, Screenshot) |

## KEY DECISIONS
- **NVM**: Lazy-loaded in .zshrc (not via OMZ plugin) — avoids ~500ms startup penalty
- **zoxide**: Replaces autojump. `z` to jump, `j` aliased for muscle memory
- **delta**: git diff pager — syntax highlighting, side-by-side, line numbers
- **prek**: Replaces pre-commit (Rust reimplementation, faster)
- **go@1.25**: Pinned version via `go@1.25` formula + symlink to `/opt/homebrew/opt/go`
- **gnopls**: Built with `GOTOOLCHAIN=go1.24.10` (build constraint), runtime uses go@1.25
- **gh/hosts.yml**: NOT tracked (OAuth tokens) — gitignored via `.gitignore_global`
- **github-copilot/apps.json**: NOT tracked (OAuth tokens) — gitignored

## CONVENTIONS
- All paths use `$HOME` instead of specific username
- `.config/` mirrors `~/.config/`
- setup.sh is idempotent (checks if already installed before each step)
- link.sh backs up files only when content differs from dotfiles version
- Gofile supports inline `GOTOOLCHAIN=<version>` metadata per package

## COMMANDS
```bash
./setup.sh          # Full setup (Homebrew, tools, Zsh, macOS defaults, etc.)
./link.sh           # Create symlinks to $HOME
./setup.sh 03       # Run a specific step only (e.g. Go tools)
brew bundle         # Install Brewfile packages
```

## NOTES
- Requires Homebrew
- link.sh auto-discovers all `.config/*` files
- opencode config uses dev schema for oh-my-opencode plugin
- `set -euo pipefail` is active in all scripts — use `|| true` for optional commands
- SDKMAN init sources with `set +u` guard (sdkman-init.sh uses ZSH_VERSION which is unbound in bash)
