# PROJECT KNOWLEDGE BASE

**Generated:** 2026-03-07
**Commit:** 4f5f06f
**Branch:** main

## OVERVIEW
macOS dotfiles management repository. Symlinks config files to $HOME, automated setup via setup.sh.

## STRUCTURE
```
dotfiles/
├── .config/              # App configs (zed, nvim, karabiner, opencode, ghostty)
│   ├── zed/settings.json
│   ├── nvim/             # Neovim config
│   ├── karabiner/        # Keyboard remapping
│   ├── opencode/         # oh-my-opencode config
│   └── ghostty/          # Terminal config
├── .zshrc               # Zsh shell config
├── .gitconfig           # Git config
├── .gitignore_global    # Global Git ignore
├── Brewfile              # Homebrew packages
├── setup.sh             # Full setup script
├── link.sh              # Symlink creator
└── README.md
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Shell config | `.zshrc` | Main entry point |
| App configs | `.config/*/` | Per-app settings |
| Install packages | `Brewfile` | Homebrew list |
| Setup automation | `setup.sh` | Full install script |
| Create symlinks | `link.sh` | Links to $HOME |

## CONVENTIONS
- All paths use `$HOME` instead of specific path.
- `.config/` mirrors `~/.config/`
- setup.sh is idempotent (checks if already installed)

## COMMANDS
```bash
./setup.sh          # Full setup (Homebrew, tools, Zsh, etc.)
./link.sh          # Create symlinks to $HOME
brew bundle        # Install Brewfile packages
```

## NOTES
- Requires Homebrew
- link.sh auto-discovers all `.config/*` files
- opencode config uses dev schema for oh-my-opencode plugin
