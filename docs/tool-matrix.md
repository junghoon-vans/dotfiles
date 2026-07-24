# Tool Matrix

## OpenCode / OpenAgent

OpenCode and OpenAgent config lives under `home/dot_config/opencode/` and is applied to `~/.config/opencode/` by chezmoi. The global Codex-style LSP MCP fallback lives at `home/dot_codex/lsp-client.json` and is applied to `~/.codex/lsp-client.json`. Global Codex custom agents are installed into `~/.codex/agents/` by `./setup.sh codex-agents`.

- `opencode.json` tracks OpenCode plugins, MCP endpoints, and native LSP mappings.
- `lsp-client.json` mirrors the OpenCode LSP mappings for OpenAgent/lsp-tools-mcp fallback use.
- `oh-my-openagent.json` tracks model routing, fallbacks, skills, and notification preferences.
- `tui.json` tracks terminal UI preferences.
- MCP endpoints include GitHub, Atlassian, Context7, gnomcp, Firecrawl, Aside-backed Playwright, and native Aside — the same set Codex registers through `setup/apps/codex-mcp.sh`, kept in sync across both agents. API keys and OAuth host files are not tracked.
- The `opencode` setup command installs `opencode-status-hud`; its installer-managed local shim lives at `~/.config/opencode/plugins/opencode-status-hud.js` and is not tracked by chezmoi.
- Optional `OPENCODE_STATUS_HUD_*` display overrides are local runtime preferences and should stay out of tracked config unless they become part of the shared baseline.
- OpenAgent uses Playwright MCP for browser automation. Brave is Brewfile-managed and selected through `PLAYWRIGHT_MCP_EXECUTABLE_PATH` in `.zshrc` when installed.

## Codex Agents and Skills

The global Codex-style LSP MCP fallback lives at `home/dot_codex/lsp-client.json` and is applied to `~/.codex/lsp-client.json`. Global Codex custom agents are installed into `~/.codex/agents/` by `./setup.sh codex-agents`.

`./setup.sh codex-agents` installs generic global custom agents from `VoltAgent/awesome-codex-subagents`. Keep private project workflow rules in repo-local `.agents/skills` or `AGENTS.md`, not in global agent files.

- Core workflow: `codebase-orchestrator`, `git-workflow-manager`, `documentation-engineer`.
- Review and QA: `code-reviewer`, `debugger`, `test-automator`, `security-auditor`.
- App development: `frontend-developer`, `golang-pro`, `typescript-pro`, `react-specialist`, `spring-boot-engineer`.
- Data and infrastructure: `sql-pro`, `postgres-pro`, `database-optimizer`, `kubernetes-specialist`, `terraform-engineer`, `deployment-engineer`.
- Domain tooling: `blockchain-developer`, `mcp-developer`.

`./setup.sh codex` installs Codex HUD from `fwyc0573/codex-hud` into `~/.local/share/codex-hud`, exposes its management commands from `~/.local/bin`, and the managed `.zshrc` routes `codex` and `codex-resume` through the HUD wrapper when it is installed. It also installs the configured `gnomcp` repo/ref into `~/.local/bin`, registers the `gnomcp@gnoverse` Codex plugin, and registers the `gnomcp` MCP server so Gno chain tools and bundled Gno audit/build/debug skills are available after restarting Codex. The default tracks the official `gnoverse/gno-mcp@v0.9.0` release; set `GNOMCP_REPO`, `GNOMCP_REF`, and `GNOMCP_RELEASE_VERSION` to pin a different release or fork.

`./setup.sh codex` (via `codex-mcp.sh`) also registers Atlassian, GitHub Copilot (bearer token from `GITHUB_PERSONAL_ACCESS_TOKEN`), Context7, Firecrawl, Aside-backed Playwright, and native Aside MCP servers — the same set OpenCode declares in `opencode.json`.

`./setup.sh codex-skills` installs global Codex skills through `npx skills`. The default set is `find-skills`, `vercel-react-best-practices`, and `golang-pro`. `./setup.sh opencode-skills` installs the same skill set for OpenCode through `npx skills --agent opencode`.

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

Agent LSP config starts Biome with `biome lsp-proxy --stdio`. This repo maps Biome only to `.json` and `.jsonc` so it does not overlap with `typescript-language-server` for JS/TS files. CSS remains covered by Biome formatting/linting, but it is not mapped as an OpenCode LSP extension because Biome CSS LSP coverage is less consistently documented across upstream docs.
