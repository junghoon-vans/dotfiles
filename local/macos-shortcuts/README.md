# macOS Shortcut Scripts

Put local, machine-specific shortcut scripts in this directory.

Tracked setup installs five macOS shortcut slots:

| Script | Shortcut |
| --- | --- |
| `1.sh` | `Ctrl+Cmd+Shift+1` |
| `2.sh` | `Ctrl+Cmd+Shift+2` |
| `5.sh` | `Ctrl+Cmd+Shift+5` |
| `6.sh` | `Ctrl+Cmd+Shift+6` |
| `7.sh` | `Ctrl+Cmd+Shift+7` |

The `*.sh` files in this directory are intentionally ignored by Git. Setup
symlinks them into `~/.local/share/dotfiles/macos-shortcuts/`, and the macOS
Quick Actions execute the symlink paths. Editing one of these ignored scripts
changes the next shortcut run without reinstalling the workflows.
