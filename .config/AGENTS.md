# .config/

App-specific configurations. Each subdirectory mirrors `~/.config/`.

## STRUCTURE
```
.config/
├── zed/settings.json       # Editor (AI, LSP, theme)
├── nvim/                   # Neovim
│   ├── init.lua
│   └── lua/config/
├── karabiner/              # Keyboard remapping
├── opencode/               # oh-my-opencode plugin config
└── ghostty/                # Terminal
```

## WHERE TO LOOK
| App | File | Purpose |
|-----|------|---------|
| Zed | `zed/settings.json` | Editor, LSP (gopls, gnopls), AI agent |
| Neovim | `nvim/init.lua` | Plugin manager (lazy.nvim) |
| Karabiner | `karabiner.json` | Key remappings |
| OpenCode | `opencode/oh-my-opencode.json` | Agent models |
| Ghostty | `ghostty/config` | Terminal settings |

## CONVENTIONS
- All paths use `$HOME` (not hardcoded usernames)
- JSON/YAML for configs
- OpenCode: dev schema, free models (big-pickle, glm-4.7-free)
