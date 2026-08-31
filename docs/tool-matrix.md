# Tool Matrix

## Oh My Pi and Codex

Oh My Pi is the primary coding agent. Its tracked configuration is
`home/dot_omp/agent/config.yml`, applied to `~/.omp/agent/config.yml`.
Codex remains available, including its HUD.

`apm.yml` pins the shared agent capabilities to reviewed upstream revisions.
APM records each global installation in untracked `~/.apm/apm.lock.yaml`:

- `apm install --global --target agent-skills --target codex` installs shared
  skills into `~/.agents/skills/`, which Oh My Pi discovers through its Agents
  skill provider.
- The same command writes the shared MCP declarations into
  `~/.codex/config.toml`; Codex reads that native configuration and Oh My Pi
  imports Codex MCP servers during discovery.
- API keys and OAuth credentials remain local. The manifest contains only
  environment references and server definitions.

Versioned local MCP runtimes are pinned to `firecrawl-mcp@3.24.0`,
`@playwright/mcp@0.0.79`, and `gnomcp@v0.11.0`. Remote HTTP MCP servers are
provider-operated and cannot be client-version-pinned.


LSP server binaries remain language-owned setup artifacts. Oh My Pi's built-in
LSP discovery uses those binaries directly; no agent-specific LSP client
fallback is maintained.

## Claude Code

`./setup.sh brew-packages` installs the `claude-code` cask for CLI bootstrap on new machines. An existing native-installer-managed `~/.local/bin/claude` (from `curl -fsSL https://claude.ai/install.sh | bash`) can intentionally take PATH precedence over Homebrew's cask binary, the same override pattern used for Hermes Agent.

`home/dot_claude/settings.json` is chezmoi-managed and applied to `~/.claude/settings.json`. Account/session/machine state (`~/.claude.json`, `~/.claude/history.jsonl`, `~/.claude/projects/`, `~/.claude/sessions/`, `~/.claude/shell-snapshots/`, and similar) is never tracked.

## Language and Harness Coverage

`mise.toml` records the repository runtime versions for languages that mise can manage, and `home/dot_config/mise/config.toml` mirrors those versions for the global `~/.config/mise/config.toml` baseline. `./setup.sh brew-packages` installs Homebrew-managed `mise`; setup language and blockchain commands sync the global mise config, run `mise install <tool>` for required runtimes, and then install runtime-adjacent tools, language servers, and chain-specific CLIs with those runtimes.

| Language / File Type | Runtime / CLI | Oh My Pi LSP | Formatter | Linter / Diagnostics | Test / Debug Harness |
| --- | --- | --- | --- | --- | --- |
| Bash / Zsh | macOS shell | `bash-language-server` | `shfmt` | `shellcheck` | `bash -n` |
| Go | Global mise config (`go = "1.25"`) + `./setup.sh go` tools in the mise Go bin dir (`~/.local/share/mise/installs/go/<version>/bin`) | `mise exec go@1.25 -- gopls` | `gofumpt` | `golangci-lint` | `delve`, `go test` |
| Gno | `./setup.sh gno` (binaries in the mise Go bin dir) | `mise exec go@1.25 -- gnopls` | - | `gnopls` diagnostics | `gno test` |
| Java | Global mise config (`java = "temurin-21"`) + `./setup.sh java` tools | `mise exec java@temurin-21 -- jdtls` with per-project `-data` | - | `jdtls` diagnostics | project build tool |
| Kotlin | Global mise config (`kotlin = "latest"`) + `./setup.sh kotlin` tools | `kotlin-language-server` | - | Kotlin LSP diagnostics | project build tool |
| Markdown | - | `marksman` | - | `marksman` diagnostics | - |
| Python | Global mise config (`python = "3.13"`) + `./setup.sh python` tools | `pyright` | `ruff format` | `ruff check`, `pyright` | project test runner |
| Rust | Global mise config (`rust = "latest"`) + `./setup.sh rust` tools | `mise exec rust@latest -- $(brew --prefix rust-analyzer)/bin/rust-analyzer` | `rustfmt` | `rust-analyzer` diagnostics | `cargo-nextest` |
| Solana / Anchor | Agave Solana CLI + `cargo build-sbf` + AVM/Anchor from `./setup.sh solana` | - | `anchor fmt` / `rustfmt` | `anchor` / Solana CLI diagnostics | `anchor test`, `solana-test-validator` |
| Sui / Move | `suiup`, Sui CLI, `move-analyzer`, and compatibility `sui-test-validator` from `./setup.sh sui` | not mapped | `sui move` | `sui move` / `move-analyzer` diagnostics | `sui move test`, `sui start --with-faucet --force-regenesis` |
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

Oh My Pi starts Biome with `biome lsp-proxy --stdio` when the server is available. This repo uses Biome only for `.json` and `.jsonc` so it does not overlap with `typescript-language-server` for JS/TS files. CSS remains covered by Biome formatting/linting; it has no dedicated LSP mapping because Biome CSS LSP coverage is less consistently documented across upstream docs.
