# .config/

App-specific configurations. Each subdirectory mirrors `~/.config/` unless explicitly documented as repo-local knowledge.

## STRUCTURE

```text
.config/
├── gh/config.yml              # GitHub CLI preferences; hosts.yml is not tracked
├── karabiner/karabiner.json   # Keyboard remapping
├── nvim/                      # Neovim config
├── opencode/                  # OpenCode and oh-my-openagent config
│   ├── opencode.json          # Plugins, MCPs, and LSP mappings
│   ├── oh-my-openagent.json   # Agent/category routing and skills
│   └── tui.json               # Terminal UI preferences
└── zed/settings.json          # Editor, LSP, theme, AI agent settings
```

## WHERE TO LOOK

| App | File | Purpose |
| --- | --- | --- |
| GitHub CLI | `gh/config.yml` | Non-secret GitHub CLI preferences |
| Zed | `zed/settings.json` | Editor, LSP, theme, AI agent settings |
| Neovim | `nvim/init.lua` | Lazy.nvim entrypoint |
| Karabiner | `karabiner/karabiner.json` | Key remappings |
| OpenCode | `opencode/opencode.json` | Plugins, MCPs, and LSP mappings |
| OpenAgent | `opencode/oh-my-openagent.json` | Models, fallbacks, skills, notifications |
| OpenCode TUI | `opencode/tui.json` | Terminal UI preferences |

## CONVENTIONS

- All paths use `$HOME` instead of hardcoded usernames.
- JSON, YAML, and Lua are the main config formats.
- OpenCode LSP mappings should match packages installed by `Brewfile` or setup scripts.
- Do not track OAuth/token files such as `gh/hosts.yml` or GitHub Copilot generated app credentials.
- This `AGENTS.md` file is repo-local documentation and is skipped by `setup/link.sh`.
