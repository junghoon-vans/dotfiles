# Tool Matrix

## Codex Agents and LSP

The global Codex-style LSP MCP fallback lives at `home/dot_codex/lsp-client.json` and is applied to `~/.codex/lsp-client.json`. Global Codex custom agents are installed into `~/.codex/agents/` by `./setup.sh codex-agents`.

`./setup.sh codex-agents` installs generic global custom agents from `VoltAgent/awesome-codex-subagents`. Keep private project workflow rules in repo-local `.agents/skills` or `AGENTS.md`, not in global agent files.

- Core workflow: `codebase-orchestrator`, `git-workflow-manager`, `documentation-engineer`.
- Review and QA: `code-reviewer`, `debugger`, `test-automator`, `security-auditor`.
- App development: `frontend-developer`, `golang-pro`, `typescript-pro`, `react-specialist`, `spring-boot-engineer`.
- Data and infrastructure: `sql-pro`, `postgres-pro`, `database-optimizer`, `kubernetes-specialist`, `terraform-engineer`, `deployment-engineer`.
- Domain tooling: `blockchain-developer`, `mcp-developer`.

`./setup.sh codex` installs the configured `gnomcp` repo/ref into `~/.local/bin`, registers the `gnomcp@gnoverse` Codex plugin, and registers the `gnomcp` MCP server so Gno chain tools and bundled Gno audit/build/debug skills are available after restarting Codex. The default tracks `junghoon-vans/gno-mcp@align-gno-interrealm-skill`; set `GNOMCP_REPO=gnoverse/gno-mcp GNOMCP_REF=v0.8.0 GNOMCP_RELEASE_VERSION=v0.8.0` to return to the upstream release.

`./setup.sh codex-skills` installs global Codex skills through `npx skills`. The default set is `ponytail`, `find-skills`, `vercel-react-best-practices`, and `golang-pro`.

## Language and Harness Coverage

`mise.toml` records the repository runtime versions for languages that mise can manage, and `home/dot_config/mise/config.toml` mirrors those versions for the global `~/.config/mise/config.toml` baseline. `./setup.sh brew-packages` installs Homebrew-managed `mise`; setup language and blockchain commands sync the global mise config, run `mise install <tool>` for required runtimes, and then install runtime-adjacent tools, language servers, and chain-specific CLIs with those runtimes.

| Language / File Type | Runtime / CLI | Agent LSP | Formatter | Linter / Diagnostics | Test / Debug Harness |
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

Agent LSP config starts Biome with `biome lsp-proxy --stdio`. This repo maps Biome only to `.json` and `.jsonc` so it does not overlap with `typescript-language-server` for JS/TS files. CSS remains covered by Biome formatting/linting, but it is not mapped as an LSP extension because Biome CSS LSP coverage is less consistently documented across upstream docs.
