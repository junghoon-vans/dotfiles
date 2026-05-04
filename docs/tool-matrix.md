# Tool Matrix

## OpenCode / OpenAgent

OpenCode and OpenAgent config lives under `home/dot_config/opencode/` and is applied to `~/.config/opencode/` by chezmoi.

- `opencode.json` tracks OpenCode plugins, MCP endpoints, and LSP mappings.
- `oh-my-openagent.json` tracks model routing, fallbacks, skills, and notification preferences.
- `tui.json` tracks terminal UI preferences.
- MCP endpoints include GitHub, Atlassian, and Context7. API keys and OAuth host files are not tracked.
- OpenAgent uses Playwright MCP for browser automation. Brave is Brewfile-managed and selected through `PLAYWRIGHT_MCP_EXECUTABLE_PATH` in `.zshrc` when installed.

## Language and Harness Coverage

`mise.toml` records the preferred runtime versions for languages that mise can manage. `./setup.sh brew-packages` installs Homebrew-managed `mise`; setup language commands run `mise install <tool>` for the selected runtime and then install runtime-adjacent tools and language servers that are not fully covered by mise.

| Language / File Type | Runtime / CLI | OpenCode LSP | Formatter | Linter / Diagnostics | Test / Debug Harness |
| --- | --- | --- | --- | --- | --- |
| Bash / Zsh | macOS shell | `bash-language-server` | `shfmt` | `shellcheck` | `bash -n` |
| Go | `mise.toml` (`go = "1.25"`) + `./setup.sh go` tools | `gopls` | `gofumpt` | `golangci-lint` | `delve`, `go test` |
| Gno | `./setup.sh gno` (`gno`) | `gnopls` | - | `gnopls` diagnostics | `gno test` |
| Java | `mise.toml` (`java = "temurin-21"`) + `./setup.sh java` tools | `jdtls` | - | `jdtls` diagnostics | project build tool |
| Kotlin | `mise.toml` (`kotlin = "latest"`) + `./setup.sh java` tools | `kotlin-language-server` | - | Kotlin LSP diagnostics | project build tool |
| Markdown | - | `marksman` | - | `marksman` diagnostics | - |
| Python | `mise.toml` (`python = "3.13"`) + `./setup.sh python` tools | `pyright` | `ruff format` | `ruff check`, `pyright` | project test runner |
| Rust | `mise.toml` (`rust = "latest"`) + `./setup.sh rust` tools | `rust-analyzer` | `rustfmt` | `rust-analyzer` diagnostics | `cargo-nextest` |
| Terraform | `terraform` | `terraform-ls` | `terraform fmt` | `terraform validate` | - |
| TypeScript / JavaScript | `mise.toml` (`node = "24"`, `bun = "latest"`) + `./setup.sh typescript` tools | `typescript-language-server` | `biome` | `biome`, TypeScript diagnostics | project test runner |
| JSON / JSONC | `./setup.sh typescript` | `biome` | `biome` | `biome` | - |
| CSS | `./setup.sh typescript` | not mapped | `biome` | `biome` | - |
| XML / XSD / XSLT / SVG | `./setup.sh xml` (`lemminx`) | `lemminx` | - | LemMinX diagnostics | - |
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
