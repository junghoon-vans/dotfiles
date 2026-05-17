# Tool Matrix

## OpenCode / OpenAgent

OpenCode and OpenAgent config lives under `home/dot_config/opencode/` and is applied to `~/.config/opencode/` by chezmoi.

- `opencode.json` tracks OpenCode plugins, MCP endpoints, and LSP mappings.
- `oh-my-openagent.json` tracks model routing, fallbacks, skills, and notification preferences.
- `tui.json` tracks terminal UI preferences.
- MCP endpoints include GitHub, Atlassian, and Context7. API keys and OAuth host files are not tracked.
- The `opencode` setup command installs `opencode-status-hud`; its installer-managed local shim lives at `~/.config/opencode/plugins/opencode-status-hud.js` and is not tracked by chezmoi.
- Optional `OPENCODE_STATUS_HUD_*` display overrides are local runtime preferences and should stay out of tracked config unless they become part of the shared baseline.
- OpenAgent uses Playwright MCP for browser automation. Brave is Brewfile-managed and selected through `PLAYWRIGHT_MCP_EXECUTABLE_PATH` in `.zshrc` when installed.

## Language and Harness Coverage

`mise.toml` records the repository runtime versions for languages that mise can manage, and `home/dot_config/mise/config.toml` mirrors those versions for the global `~/.config/mise/config.toml` baseline. `./setup.sh brew-packages` installs Homebrew-managed `mise`; setup language and blockchain commands sync the global mise config, run `mise install <tool>` for required runtimes, and then install runtime-adjacent tools, language servers, and chain-specific CLIs with those runtimes.

| Language / File Type | Runtime / CLI | OpenCode LSP | Formatter | Linter / Diagnostics | Test / Debug Harness |
| --- | --- | --- | --- | --- | --- |
| Bash / Zsh | macOS shell | `bash-language-server` | `shfmt` | `shellcheck` | `bash -n` |
| Go | Global mise config (`go = "1.25"`) + `./setup.sh go` tools in `~/.local/bin` | `mise exec go@1.25 -- gopls` | `gofumpt` | `golangci-lint` | `delve`, `go test` |
| Gno | `./setup.sh gno` (`~/.local/bin/gno`) | `mise exec go@1.25 -- gnopls` | - | `gnopls` diagnostics | `gno test` |
| Java | Global mise config (`java = "temurin-21"`) + `./setup.sh java` tools | `mise exec java@temurin-21 -- jdtls` with per-project `-data` | - | `jdtls` diagnostics | project build tool |
| Kotlin | Global mise config (`kotlin = "latest"`) + `./setup.sh kotlin` tools | `kotlin-language-server` | - | Kotlin LSP diagnostics | project build tool |
| Markdown | - | `marksman` | - | `marksman` diagnostics | - |
| Python | Global mise config (`python = "3.13"`) + `./setup.sh python` tools | `pyright` | `ruff format` | `ruff check`, `pyright` | project test runner |
| Rust | Global mise config (`rust = "latest"`) + `./setup.sh rust` tools | `mise exec rust@latest -- $(brew --prefix rust-analyzer)/bin/rust-analyzer` | `rustfmt` | `rust-analyzer` diagnostics | `cargo-nextest` |
| Solana / Anchor | Agave Solana CLI + `cargo build-sbf` + AVM/Anchor from `./setup.sh solana` | - | `anchor fmt` / `rustfmt` | `anchor` / Solana CLI diagnostics | `anchor test`, `solana-test-validator` |
| Terraform | `terraform` | `terraform-ls` | `terraform fmt` | `terraform validate` | - |
| TypeScript / JavaScript | Global mise config (`node = "24"` + Corepack pnpm, `bun = "latest"`) + `./setup.sh typescript` tools | `mise exec node@24 bun@latest -- typescript-language-server` | `biome` | `biome`, TypeScript diagnostics | project test runner |
| JSON / JSONC | `./setup.sh typescript` | `biome` | `biome` | `biome` | - |
| CSS | `./setup.sh typescript` | not mapped | `biome` | `biome` | - |
| XML / XSD / XSLT / SVG | `./setup.sh xml` (`lemminx.jar`) | `mise exec java@temurin-21 -- java -jar lemminx.jar` | - | LemMinX diagnostics | - |
| YAML | - | `yaml-language-server` | `yamlfmt` | YAML LSP diagnostics | - |
| GitHub Actions | `act` | `yaml-language-server` | `yamlfmt` | `actionlint` | `act` |

## Repository Checks

Run the same local checks used by CI with:

```bash
./setup.sh check
```

`check` validates shell syntax, optionally runs `shellcheck` and `actionlint`, parses tracked strict JSON config, performs a lightweight Zed JSONC sanity check, checks `Brewfile` syntax, runs `git diff --check`, and executes the setup smoke test.

## Biome LSP Scope

OpenCode starts Biome with `biome lsp-proxy --stdio`. This repo maps Biome only to `.json` and `.jsonc` so it does not overlap with `typescript-language-server` for JS/TS files. CSS remains covered by Biome formatting/linting, but it is not mapped as an OpenCode LSP extension because Biome CSS LSP coverage is less consistently documented across upstream docs.
