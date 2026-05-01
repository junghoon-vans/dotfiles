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
└── opencode/               # openagent plugin config
```

## WHERE TO LOOK
| App | File | Purpose |
|-----|------|---------|
| Zed | `zed/settings.json` | Editor, LSP (gopls, gnopls), AI agent |
| Neovim | `nvim/init.lua` | Plugin manager (lazy.nvim) |
| Karabiner | `karabiner.json` | Key remappings |
| OpenCode | `opencode/oh-my-openagent.json` | Agent models |

## CONVENTIONS
- All paths use `$HOME` (not hardcoded usernames)
- JSON, YAML, and Lua for configs
- OpenCode: dev schema; current tracked routing uses GPT/Codex models in `oh-my-openagent.json`
