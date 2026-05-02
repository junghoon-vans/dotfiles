# Tool Matrix

## OpenCode / OpenAgent

OpenCode and OpenAgent config lives under `.config/opencode/`.

- `opencode.json` tracks OpenCode plugins, MCP endpoints, and LSP mappings.
- `oh-my-openagent.json` tracks model routing, fallbacks, skills, and notification preferences.
- `tui.json` tracks terminal UI preferences.
- MCP endpoints include GitHub, Atlassian, and Context7. API keys and OAuth host files are not tracked.

## Language and Harness Coverage

| Language / File Type | Runtime / CLI | OpenCode LSP | Formatter | Linter / Diagnostics | Test / Debug Harness |
| --- | --- | --- | --- | --- | --- |
| Bash / Zsh | macOS shell | `bash-language-server` | `shfmt` | `shellcheck` | `bash -n` |
| Go | `go@1.25` | `gopls` | `gofumpt` | `golangci-lint` | `delve`, `go test` |
| Gno | `gno` | `gnopls` | - | `gnopls` diagnostics | `gno test` |
| Java | SDKMAN Java 11/17/21 | `jdtls` | - | `jdtls` diagnostics | project build tool |
| Kotlin | SDKMAN Kotlin | `kotlin-language-server` | - | Kotlin LSP diagnostics | project build tool |
| Markdown | - | `marksman` | - | `marksman` diagnostics | - |
| Python | `uv` | `pyright` | `ruff format` | `ruff check`, `pyright` | project test runner |
| Rust | `rustup` | `rust-analyzer` | `rustfmt` | `rust-analyzer` diagnostics | `cargo-nextest` |
| Terraform | `terraform` | `terraform-ls` | `terraform fmt` | `terraform validate` | - |
| TypeScript / JavaScript | NVM Node.js LTS, Bun | `typescript-language-server` | `biome` | `biome`, TypeScript diagnostics | project test runner |
| JSON / JSONC | NVM Node.js LTS, Bun | `biome` | `biome` | `biome` | - |
| CSS | NVM Node.js LTS, Bun | not mapped | `biome` | `biome` | - |
| YAML | - | `yaml-language-server` | `yamlfmt` | YAML LSP diagnostics | - |

## Repository Checks

Run the same local checks used by CI with:

```bash
./setup.sh check
```

`check` validates shell syntax, optionally runs `shellcheck`, parses tracked strict JSON config, performs a lightweight Zed JSONC sanity check, checks `Brewfile` syntax, runs `git diff --check`, and executes the setup smoke test.

## Biome LSP Scope

OpenCode starts Biome with `biome lsp-proxy --stdio`. This repo maps Biome only to `.json` and `.jsonc` so it does not overlap with `typescript-language-server` for JS/TS files. CSS remains covered by Biome formatting/linting, but it is not mapped as an OpenCode LSP extension because Biome CSS LSP coverage is less consistently documented across upstream docs.
