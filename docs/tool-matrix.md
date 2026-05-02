# Tool Matrix

## OpenCode / OpenAgent

OpenCode and OpenAgent config lives under `.config/opencode/`.

- `opencode.json` tracks OpenCode plugins, MCP endpoints, and LSP mappings.
- `oh-my-openagent.json` tracks model routing, fallbacks, skills, and notification preferences.
- `tui.json` tracks terminal UI preferences.
- MCP endpoints include GitHub, Atlassian, and Context7. API keys and OAuth host files are not tracked.
- OpenAgent uses Playwright MCP for browser automation. Brave is Brewfile-managed and selected through `PLAYWRIGHT_MCP_EXECUTABLE_PATH` in `.zshrc` when installed.

## Language and Harness Coverage

| Language / File Type | Runtime / CLI | OpenCode LSP | Formatter | Linter / Diagnostics | Test / Debug Harness |
| --- | --- | --- | --- | --- | --- |
| Bash / Zsh | macOS shell | `bash-language-server` | `shfmt` | `shellcheck` | `bash -n` |
| Go | `./setup.sh go` (`go@1.25`) | `gopls` | `gofumpt` | `golangci-lint` | `delve`, `go test` |
| Gno | `./setup.sh gno` (`gno`) | `gnopls` | - | `gnopls` diagnostics | `gno test` |
| Java | `./setup.sh java` (SDKMAN Java 11/17/21) | `jdtls` | - | `jdtls` diagnostics | project build tool |
| Kotlin | `./setup.sh java` (SDKMAN Kotlin) | `kotlin-language-server` | - | Kotlin LSP diagnostics | project build tool |
| Markdown | - | `marksman` | - | `marksman` diagnostics | - |
| Python | `./setup.sh python` (`uv` + Python) | `pyright` | `ruff format` | `ruff check`, `pyright` | project test runner |
| Rust | `./setup.sh rust` (`rustup`) | `rust-analyzer` | `rustfmt` | `rust-analyzer` diagnostics | `cargo-nextest` |
| Terraform | `terraform` | `terraform-ls` | `terraform fmt` | `terraform validate` | - |
| TypeScript / JavaScript | `./setup.sh typescript` | `typescript-language-server` | `biome` | `biome`, TypeScript diagnostics | project test runner |
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
