#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETUP_SH="$REPO_ROOT/setup.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

FAKE_HOME="$TMP_DIR/home"
FAKE_BIN="$TMP_DIR/bin"
FAKE_GOBIN="$TMP_DIR/fake-gobin"
FAKE_GOPATH="$TMP_DIR/fake-gopath"
FAKE_GOROOT="$TMP_DIR/fake-goroot"
LOG_FILE="$TMP_DIR/commands.log"

mkdir -p "$FAKE_HOME" "$FAKE_BIN" "$FAKE_GOBIN" "$FAKE_GOPATH/bin" "$FAKE_GOROOT/bin"

cat >"$FAKE_BIN/go" <<EOF
#!/bin/bash
printf 'go %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "version" ]; then
  printf 'go version go1.25.6 darwin/arm64\n'
fi
EOF

cat >"$FAKE_GOROOT/bin/go" <<EOF
#!/bin/bash
printf 'goroot-go %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "version" ]; then
  printf 'go version go1.25.6 darwin/arm64\n'
fi
EOF

cat >"$FAKE_BIN/bun" <<EOF
#!/bin/bash
printf 'bun %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "--version" ]; then
  printf '1.2.0\n'
fi
EOF

cat >"$FAKE_BIN/curl" <<EOF
#!/bin/bash
printf 'curl %s\n' "\$*" >> "$LOG_FILE"
exit 0
EOF

cat >"$FAKE_BIN/brew" <<EOF
#!/bin/bash
if [ "\${1:-}" = "list" ]; then
  exit 0
fi
if [ "\${1:-}" = "--prefix" ] && [ "\${2:-}" = "go@1.25" ]; then
  printf '%s\n' "$TMP_DIR/fake-go-prefix"
  exit 0
fi
if [ "\${1:-}" = "--prefix" ]; then
  printf '%s\n' "$TMP_DIR/fake-homebrew"
  exit 0
fi
printf 'brew %s\n' "\$*" >> "$LOG_FILE"
EOF

cat >"$FAKE_BIN/mise" <<EOF
#!/bin/bash
printf 'mise %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "install" ] && [ "\${2:-}" = "--dry-run-code" ]; then
  exit 1
fi
if [ "\${1:-}" = "exec" ] && [ "\${2:-}" = "--" ]; then
  shift 2
  printf '%s\n' "\$*" >> "$LOG_FILE"
  case "\${1:-}" in
    go)
      if [ "\${2:-}" = "env" ]; then
        case "\${3:-}" in
          GOBIN)
            printf '%s\n' "$FAKE_GOBIN"
            exit 0
            ;;
          GOPATH)
            printf '%s\n' "$FAKE_GOPATH"
            exit 0
            ;;
          GOROOT)
            printf '%s\n' "$FAKE_GOROOT"
            exit 0
            ;;
        esac
      fi
      if [ "\${2:-}" = "version" ]; then
        printf 'go version go1.25.6 darwin/arm64\n'
      fi
      ;;
    bun)
      if [ "\${2:-}" = "--version" ]; then
        printf '1.2.0\n'
      fi
      ;;
    node)
      if [ "\${2:-}" = "--version" ]; then
        printf 'v24.0.0\n'
      fi
      ;;
    pnpm)
      if [ "\${2:-}" = "--version" ]; then
        printf '10.0.0\n'
      fi
      ;;
  esac
fi
exit 0
EOF

chmod +x "$FAKE_BIN/go" "$FAKE_GOROOT/bin/go" "$FAKE_BIN/bun" "$FAKE_BIN/curl" "$FAKE_BIN/brew" "$FAKE_BIN/mise"

export HOME="$FAKE_HOME"
export PATH="$FAKE_BIN:$PATH"

HELP_OUTPUT="$($SETUP_SH --help)"
printf '%s' "$HELP_OUTPUT" | grep -q 'opencode'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install OpenCode and bootstrap oh-my-openagent'
printf '%s' "$HELP_OUTPUT" | grep -q 'Run selected blockchain tooling commands'
printf '%s' "$HELP_OUTPUT" | grep -q 'Inspect host prerequisites'
printf '%s' "$HELP_OUTPUT" | grep -q 'Remove managed dotfile backup files created before chezmoi apply'
printf '%s' "$HELP_OUTPUT" | grep -q 'Language commands:'
printf '%s' "$HELP_OUTPUT" | grep -q 'Blockchain commands:'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install Go via mise plus Go formatter/linter tools'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install Kotlin via mise plus Kotlin language server'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install TypeScript, TypeScript LSP, and Biome'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install Gno CLI and gnopls using mise-managed Go'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install Solana CLI and Anchor tooling'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install Eclipse LemMinX XML language server'
printf '%s' "$HELP_OUTPUT" | grep -q 'Installs the configured Go runtime before Gno tooling'
printf '%s' "$HELP_OUTPUT" | grep -q 'Installs the configured Rust runtime before Solana and Anchor tooling'
printf '%s' "$HELP_OUTPUT" | grep -q 'Installs the configured Java runtime before LemMinX'
printf '%s' "$HELP_OUTPUT" | grep -q 'Installs the configured Bun runtime before TypeScript tooling'
printf '%s' "$HELP_OUTPUT" | grep -q 'Enables Corepack and installs pnpm with the configured Node runtime'
printf '%s' "$HELP_OUTPUT" | grep -q -- '--yes'
printf '%s' "$HELP_OUTPUT" | grep -q -- '--no-input'
printf '%s' "$HELP_OUTPUT" | grep -q -- '--dry-run'
printf '%s' "$HELP_OUTPUT" | grep -q -- '--skip COMMAND'

while IFS= read -r language_name; do
    LANGUAGE_COMMAND_OUTPUT="$($SETUP_SH --dry-run "$language_name")"
    printf '%s' "$LANGUAGE_COMMAND_OUTPUT" | grep -q "^  ${language_name}[[:space:]]"
    grep -Eq "(^|[[:space:]])${language_name}([[:space:];]|$)" "$REPO_ROOT/setup/commands/30-languages"
done < <(for path in "$REPO_ROOT"/setup/languages/*.sh; do basename "${path%.sh}"; done | sort)

while IFS= read -r blockchain_name; do
    BLOCKCHAIN_COMMAND_OUTPUT="$($SETUP_SH --dry-run "$blockchain_name")"
    printf '%s' "$BLOCKCHAIN_COMMAND_OUTPUT" | grep -q "^  ${blockchain_name}[[:space:]]"
    grep -Eq "(^|[[:space:]])${blockchain_name}([[:space:];]|$)" "$REPO_ROOT/setup/commands/35-blockchain"
done < <(for path in "$REPO_ROOT"/setup/blockchain/*.sh; do basename "${path%.sh}"; done | sort)

EXPECTED_LANGUAGE_ORDER="go node bun java kotlin xml rust python typescript"
ACTUAL_LANGUAGE_ORDER="$(grep '^for language_name in ' "$REPO_ROOT/setup/commands/30-languages" | sed 's/^for language_name in //; s/; do$//')"
if [ "$ACTUAL_LANGUAGE_ORDER" != "$EXPECTED_LANGUAGE_ORDER" ]; then
    printf 'languages umbrella order changed: expected "%s", got "%s"\n' "$EXPECTED_LANGUAGE_ORDER" "$ACTUAL_LANGUAGE_ORDER" >&2
    exit 1
fi

EXPECTED_BLOCKCHAIN_ORDER="solana gno"
ACTUAL_BLOCKCHAIN_ORDER="$(grep '^for blockchain_name in ' "$REPO_ROOT/setup/commands/35-blockchain" | sed 's/^for blockchain_name in //; s/; do$//')"
if [ "$ACTUAL_BLOCKCHAIN_ORDER" != "$EXPECTED_BLOCKCHAIN_ORDER" ]; then
    printf 'blockchain umbrella order changed: expected "%s", got "%s"\n' "$EXPECTED_BLOCKCHAIN_ORDER" "$ACTUAL_BLOCKCHAIN_ORDER" >&2
    exit 1
fi

LANGUAGE_PROMPT_SETUP_DIR="$TMP_DIR/language-prompt-setup"
LANGUAGE_PROMPT_LOG="$TMP_DIR/language-prompt.log"
mkdir -p "$LANGUAGE_PROMPT_SETUP_DIR/languages"
for language_name in $EXPECTED_LANGUAGE_ORDER; do
    cat >"$LANGUAGE_PROMPT_SETUP_DIR/languages/$language_name.sh" <<'EOF'
#!/bin/bash
printf '%s\n' "$(basename "$0")" >> "$LANGUAGE_PROMPT_LOG"
EOF
    chmod +x "$LANGUAGE_PROMPT_SETUP_DIR/languages/$language_name.sh"
done

LANGUAGE_PROMPT_OUTPUT="$(SETUP_DIR="$LANGUAGE_PROMPT_SETUP_DIR" SETUP_YES=1 SETUP_NO_INPUT=1 LANGUAGE_PROMPT_LOG="$LANGUAGE_PROMPT_LOG" bash "$REPO_ROOT/setup/commands/30-languages")"
printf '%s' "$LANGUAGE_PROMPT_OUTPUT" | grep -q "Run language command 'go'? \[Y/n\] yes (--yes)"
printf '%s' "$LANGUAGE_PROMPT_OUTPUT" | grep -q "Run language command 'xml'? \[Y/n\] yes (--yes)"
read -r -a expected_languages <<<"$EXPECTED_LANGUAGE_ORDER"
EXPECTED_LANGUAGE_RUNS="$(printf '%s.sh\n' "${expected_languages[@]}")"
ACTUAL_LANGUAGE_RUNS="$(cat "$LANGUAGE_PROMPT_LOG")"
if [ "$ACTUAL_LANGUAGE_RUNS" != "$EXPECTED_LANGUAGE_RUNS" ]; then
    printf 'languages umbrella run order changed: expected "%s", got "%s"\n' "$EXPECTED_LANGUAGE_RUNS" "$ACTUAL_LANGUAGE_RUNS" >&2
    exit 1
fi

: >"$LANGUAGE_PROMPT_LOG"
LANGUAGE_SKIP_PROMPT_OUTPUT="$(SETUP_DIR="$LANGUAGE_PROMPT_SETUP_DIR" SETUP_YES=1 SETUP_NO_INPUT=1 SETUP_SKIP_COMMANDS=' rust typescript ' LANGUAGE_PROMPT_LOG="$LANGUAGE_PROMPT_LOG" bash "$REPO_ROOT/setup/commands/30-languages")"
printf '%s' "$LANGUAGE_SKIP_PROMPT_OUTPUT" | grep -q 'Skipping language command: rust'
printf '%s' "$LANGUAGE_SKIP_PROMPT_OUTPUT" | grep -q 'Skipping language command: typescript'
if printf '%s' "$LANGUAGE_SKIP_PROMPT_OUTPUT" | grep -q "Run language command 'rust'?"; then
    printf 'skipped language command should not prompt: rust\n' >&2
    exit 1
fi
if grep -q '^rust.sh$\|^typescript.sh$' "$LANGUAGE_PROMPT_LOG"; then
    printf 'skipped language commands should not run\n' >&2
    exit 1
fi

BLOCKCHAIN_PROMPT_SETUP_DIR="$TMP_DIR/blockchain-prompt-setup"
BLOCKCHAIN_PROMPT_LOG="$TMP_DIR/blockchain-prompt.log"
mkdir -p "$BLOCKCHAIN_PROMPT_SETUP_DIR/blockchain"
for blockchain_name in $EXPECTED_BLOCKCHAIN_ORDER; do
    cat >"$BLOCKCHAIN_PROMPT_SETUP_DIR/blockchain/$blockchain_name.sh" <<'EOF'
#!/bin/bash
printf '%s\n' "$(basename "$0")" >> "$BLOCKCHAIN_PROMPT_LOG"
EOF
    chmod +x "$BLOCKCHAIN_PROMPT_SETUP_DIR/blockchain/$blockchain_name.sh"
done

BLOCKCHAIN_PROMPT_OUTPUT="$(SETUP_DIR="$BLOCKCHAIN_PROMPT_SETUP_DIR" SETUP_YES=1 SETUP_NO_INPUT=1 BLOCKCHAIN_PROMPT_LOG="$BLOCKCHAIN_PROMPT_LOG" bash "$REPO_ROOT/setup/commands/35-blockchain")"
printf '%s' "$BLOCKCHAIN_PROMPT_OUTPUT" | grep -q "Run blockchain command 'solana'? \[Y/n\] yes (--yes)"
printf '%s' "$BLOCKCHAIN_PROMPT_OUTPUT" | grep -q "Run blockchain command 'gno'? \[Y/n\] yes (--yes)"
read -r -a expected_blockchains <<<"$EXPECTED_BLOCKCHAIN_ORDER"
EXPECTED_BLOCKCHAIN_RUNS="$(printf '%s.sh\n' "${expected_blockchains[@]}")"
ACTUAL_BLOCKCHAIN_RUNS="$(cat "$BLOCKCHAIN_PROMPT_LOG")"
if [ "$ACTUAL_BLOCKCHAIN_RUNS" != "$EXPECTED_BLOCKCHAIN_RUNS" ]; then
    printf 'blockchain umbrella run order changed: expected "%s", got "%s"\n' "$EXPECTED_BLOCKCHAIN_RUNS" "$ACTUAL_BLOCKCHAIN_RUNS" >&2
    exit 1
fi

: >"$BLOCKCHAIN_PROMPT_LOG"
BLOCKCHAIN_SKIP_PROMPT_OUTPUT="$(SETUP_DIR="$BLOCKCHAIN_PROMPT_SETUP_DIR" SETUP_YES=1 SETUP_NO_INPUT=1 SETUP_SKIP_COMMANDS=' gno ' BLOCKCHAIN_PROMPT_LOG="$BLOCKCHAIN_PROMPT_LOG" bash "$REPO_ROOT/setup/commands/35-blockchain")"
printf '%s' "$BLOCKCHAIN_SKIP_PROMPT_OUTPUT" | grep -q 'Skipping blockchain command: gno'
if printf '%s' "$BLOCKCHAIN_SKIP_PROMPT_OUTPUT" | grep -q "Run blockchain command 'gno'?"; then
    printf 'skipped blockchain command should not prompt: gno\n' >&2
    exit 1
fi
if grep -q '^gno.sh$' "$BLOCKCHAIN_PROMPT_LOG"; then
    printf 'skipped blockchain command should not run\n' >&2
    exit 1
fi

python3 - "$REPO_ROOT/home/dot_config/opencode/opencode.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as config_file:
    config = json.load(config_file)

expected_commands = {
    "gopls": ["/bin/bash", "-lc", 'PATH="$HOME/.local/bin:$PATH" exec mise exec go@1.25 -- gopls'],
    "gnopls": ["/bin/bash", "-lc", 'PATH="$HOME/.local/bin:$PATH" exec mise exec go@1.25 -- gnopls -mode=stdio'],
    "jdtls": ["/bin/bash", "-lc", "project_hash=$(printf \"%s\" \"$PWD\" | shasum | cut -d\" \" -f1); mkdir -p \"$HOME/Library/Caches/jdtls/workspaces\"; exec mise exec java@temurin-21 -- jdtls -data \"$HOME/Library/Caches/jdtls/workspaces/$project_hash\""],
    "kotlin-ls": ["/bin/bash", "-lc", "exec mise exec java@temurin-21 kotlin@latest -- kotlin-language-server"],
    "pyright": ["/bin/bash", "-lc", "exec mise exec python@3.13 -- pyright-langserver --stdio"],
    "rust": ["/bin/bash", "-lc", 'exec mise exec rust@latest -- "$(brew --prefix rust-analyzer)/bin/rust-analyzer"'],
    "typescript-language-server": ["/bin/bash", "-lc", 'PATH="$(mise exec bun@latest -- bun pm bin -g):$PATH" exec mise exec node@24 bun@latest -- typescript-language-server --stdio'],
    "xml": ["/bin/bash", "-lc", 'exec mise exec java@temurin-21 -- java ${LEMMINX_JAVA_OPTS:-} -jar "$HOME/.local/share/lemminx/lemminx.jar"'],
}
for lsp_name, command in expected_commands.items():
    actual = config["lsp"][lsp_name]["command"]
    if actual != command:
        raise SystemExit(f"OpenCode {lsp_name} command should be {command}, got {actual}")
    if "~" in " ".join(actual):
        raise SystemExit(f"OpenCode {lsp_name} command should not rely on tilde expansion")

    for forbidden_path in ("$HOME/workspace/dotfiles", "~/workspace/dotfiles"):
        if forbidden_path in " ".join(actual):
            raise SystemExit(f"OpenCode {lsp_name} command should not depend on local checkout path {forbidden_path}")

    for forbidden_exec in ('exec "$HOME/.local/bin/',):
        if forbidden_exec in " ".join(actual):
            raise SystemExit(f"OpenCode {lsp_name} command should not directly exec local bin wrappers")

if config["lsp"]["xml"]["extensions"] != [".xml", ".xsd", ".xsl", ".xslt", ".svg"]:
    raise SystemExit("OpenCode XML LSP extensions changed")
PY

python3 - "$REPO_ROOT/home/dot_config/zed/settings.json" <<'PY'
import json
import re
import sys

with open(sys.argv[1], encoding="utf-8") as config_file:
    lines = [line for line in config_file if not line.lstrip().startswith("//")]

content = "".join(lines)
content = re.sub(r",(\s*[}\]])", r"\1", content)
config = json.loads(content)

expected_commands = {
    "gopls": ["-lc", 'PATH="$HOME/.local/bin:$PATH" exec mise exec go@1.25 -- gopls'],
    "gnopls": ["-lc", 'PATH="$HOME/.local/bin:$PATH" exec mise exec go@1.25 -- gnopls -mode=stdio'],
}
for lsp_name, arguments in expected_commands.items():
    binary = config["lsp"][lsp_name]["binary"]
    if binary["path"] != "/bin/bash":
        raise SystemExit(f"Zed {lsp_name} binary should launch through /bin/bash")
    if binary["arguments"] != arguments:
        raise SystemExit(f"Zed {lsp_name} arguments should be {arguments}, got {binary['arguments']}")
PY

DRY_RUN_OUTPUT="$($SETUP_SH --dry-run --skip macos)"
printf '%s' "$DRY_RUN_OUTPUT" | grep -q 'Selected setup commands'
printf '%s' "$DRY_RUN_OUTPUT" | grep -q 'languages'
printf '%s' "$DRY_RUN_OUTPUT" | grep -q 'blockchain'
printf '%s' "$DRY_RUN_OUTPUT" | grep -q '^  karabiner[[:space:]]\+Install Karabiner-Elements'
printf '%s' "$DRY_RUN_OUTPUT" | grep -q 'Skipping command: macos'
if printf '%s' "$DRY_RUN_OUTPUT" | grep -q '^  macos[[:space:]]'; then
    printf 'dry-run selected commands should not include skipped macos command\n' >&2
    exit 1
fi

BLOCKCHAIN_SKIP_OUTPUT="$($SETUP_SH --dry-run --skip blockchain)"
printf '%s' "$BLOCKCHAIN_SKIP_OUTPUT" | grep -q 'Skipping command: blockchain'
if printf '%s' "$BLOCKCHAIN_SKIP_OUTPUT" | grep -q '^  blockchain[[:space:]]'; then
    printf 'dry-run selected commands should not include skipped blockchain command\n' >&2
    exit 1
fi

KARABINER_SKIP_OUTPUT="$($SETUP_SH --dry-run --skip karabiner)"
printf '%s' "$KARABINER_SKIP_OUTPUT" | grep -q 'Skipping command: karabiner'
if printf '%s' "$KARABINER_SKIP_OUTPUT" | grep -q '^  karabiner[[:space:]]'; then
    printf 'dry-run selected commands should not include skipped karabiner command\n' >&2
    exit 1
fi

NO_INPUT_OUTPUT="$($SETUP_SH --no-input --dry-run bootstrap)"
printf '%s' "$NO_INPUT_OUTPUT" | grep -q 'bootstrap'
printf '%s' "$NO_INPUT_OUTPUT" | grep -q 'Install Homebrew if it is missing'

LANGUAGE_DRY_RUN_OUTPUT="$($SETUP_SH --dry-run go gno xml solana typescript python)"
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  go[[:space:]]\+Install Go via mise'
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  gno[[:space:]]\+Install Gno CLI'
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  xml[[:space:]]\+Install Eclipse LemMinX XML language server'
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  solana[[:space:]]\+Install Solana CLI and Anchor tooling'
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  typescript[[:space:]]\+Install TypeScript'
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  python[[:space:]]\+Install Python via mise'

LANGUAGE_SKIP_OUTPUT="$($SETUP_SH --dry-run --skip gno go gno)"
printf '%s' "$LANGUAGE_SKIP_OUTPUT" | grep -q 'Skipping command: gno'
printf '%s' "$LANGUAGE_SKIP_OUTPUT" | grep -q '^  go[[:space:]]\+Install Go via mise'
if printf '%s' "$LANGUAGE_SKIP_OUTPUT" | grep -q '^  gno[[:space:]]'; then
    printf 'dry-run selected commands should not include skipped gno command\n' >&2
    exit 1
fi

BREW_PACKAGES_HOME="$TMP_DIR/brew-packages-home"
BREW_PACKAGES_BIN="$TMP_DIR/brew-packages-bin"
BREW_PACKAGES_LOG="$TMP_DIR/brew-packages.log"
mkdir -p "$BREW_PACKAGES_HOME" "$BREW_PACKAGES_BIN"
cat >"$BREW_PACKAGES_BIN/brew" <<'EOF'
#!/bin/bash
printf 'brew %s\n' "$*" >> "$BREW_PACKAGES_LOG"
case "${1:-}" in
  list)
    exit 1
    ;;
  --prefix)
    printf '%s\n' "$BREW_PACKAGES_HOME/fake-homebrew"
    ;;
esac
exit 0
EOF
cat >"$BREW_PACKAGES_BIN/mise" <<'EOF'
#!/bin/bash
printf 'mise %s\n' "$*" >> "$BREW_PACKAGES_LOG"
exit 0
EOF
chmod +x "$BREW_PACKAGES_BIN/brew" "$BREW_PACKAGES_BIN/mise"
BREW_PACKAGES_PATH="$BREW_PACKAGES_BIN:/usr/bin:/bin"
env HOME="$BREW_PACKAGES_HOME" PATH="$BREW_PACKAGES_PATH" BREW_PACKAGES_HOME="$BREW_PACKAGES_HOME" BREW_PACKAGES_LOG="$BREW_PACKAGES_LOG" bash "$REPO_ROOT/setup/commands/20-brew-packages" >/dev/null
grep -q 'brew bundle check' "$BREW_PACKAGES_LOG"
if grep -q 'mise install' "$BREW_PACKAGES_LOG"; then
    printf 'brew-packages should not install all mise runtimes\n' >&2
    exit 1
fi

if DOCTOR_SKIP_OUTPUT="$($SETUP_SH --dry-run --skip doctor doctor 2>&1)"; then
    printf 'skipping the only selected utility command should fail\n' >&2
    exit 1
fi
printf '%s' "$DOCTOR_SKIP_OUTPUT" | grep -q 'All selected commands were skipped: doctor'

NODE_FAIL_HOME="$TMP_DIR/node-fail-home"
NODE_FAIL_BIN="$TMP_DIR/node-fail-bin"
mkdir -p "$NODE_FAIL_HOME" "$NODE_FAIL_BIN"
cat >"$NODE_FAIL_BIN/curl" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$NODE_FAIL_BIN/curl"
NODE_FAIL_OUTPUT="$TMP_DIR/node-fail-output"
if HOME="$NODE_FAIL_HOME" PATH="$NODE_FAIL_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/node.sh" >"$NODE_FAIL_OUTPUT" 2>&1; then
    printf 'node installer should fail when mise is missing\n' >&2
    exit 1
fi
grep -q 'mise is required to install Node.js' "$NODE_FAIL_OUTPUT"

JAVA_FAIL_HOME="$TMP_DIR/java-fail-home"
JAVA_FAIL_BIN="$TMP_DIR/java-fail-bin"
mkdir -p "$JAVA_FAIL_HOME" "$JAVA_FAIL_BIN"
cat >"$JAVA_FAIL_BIN/curl" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$JAVA_FAIL_BIN/curl"
JAVA_FAIL_OUTPUT="$TMP_DIR/java-fail-output"
if HOME="$JAVA_FAIL_HOME" PATH="$JAVA_FAIL_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/java.sh" >"$JAVA_FAIL_OUTPUT" 2>&1; then
    printf 'java installer should fail when mise is missing\n' >&2
    exit 1
fi
grep -q 'mise is required to install Java' "$JAVA_FAIL_OUTPUT"

KOTLIN_FAIL_HOME="$TMP_DIR/kotlin-fail-home"
KOTLIN_FAIL_BIN="$TMP_DIR/kotlin-fail-bin"
mkdir -p "$KOTLIN_FAIL_HOME" "$KOTLIN_FAIL_BIN"
cat >"$KOTLIN_FAIL_BIN/curl" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$KOTLIN_FAIL_BIN/curl"
KOTLIN_FAIL_OUTPUT="$TMP_DIR/kotlin-fail-output"
if HOME="$KOTLIN_FAIL_HOME" PATH="$KOTLIN_FAIL_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/kotlin.sh" >"$KOTLIN_FAIL_OUTPUT" 2>&1; then
    printf 'kotlin installer should fail when mise is missing\n' >&2
    exit 1
fi
grep -q 'mise is required to install Kotlin' "$KOTLIN_FAIL_OUTPUT"

RUST_HOME="$TMP_DIR/rust-home"
RUST_BIN="$TMP_DIR/rust-bin"
RUST_HOMEBREW_PREFIX="$TMP_DIR/rust-homebrew"
RUST_TOOLCHAIN_BIN="$TMP_DIR/rust-toolchain-bin"
RUST_LOG="$TMP_DIR/rust.log"
mkdir -p "$RUST_HOME" "$RUST_BIN" "$RUST_HOMEBREW_PREFIX/bin" "$RUST_TOOLCHAIN_BIN"
cat >"$RUST_BIN/mise" <<'EOF'
#!/bin/bash
printf 'mise %s\n' "$*" >> "$RUST_LOG"
if [ "${1:-}" = "install" ] && [ "${2:-}" = "rust" ]; then
  exit 0
fi
if [ "${1:-}" = "exec" ] && [ "${2:-}" = "--" ]; then
  shift 2
  printf '%s\n' "$*" >> "$RUST_LOG"
  if [ "${1:-}" = "rustc" ] && [ "${2:-}" = "--version" ]; then
    printf 'rustc 1.90.0\n'
    exit 0
  fi
  PATH="$RUST_TOOLCHAIN_BIN:$PATH" exec "$@"
fi
exit 0
EOF
cat >"$RUST_BIN/brew" <<'EOF'
#!/bin/bash
printf 'brew %s\n' "$*" >> "$RUST_LOG"
if [ "${1:-}" = "list" ]; then
  exit 0
fi
if [ "${1:-}" = "--prefix" ] && [ "${2:-}" = "rust-analyzer" ]; then
  printf '%s\n' "$RUST_HOMEBREW_PREFIX"
  exit 0
fi
if [ "${1:-}" = "--prefix" ]; then
  printf '%s\n' "$RUST_HOMEBREW_PREFIX"
  exit 0
fi
exit 0
EOF
cat >"$RUST_TOOLCHAIN_BIN/rustc" <<'EOF'
#!/bin/bash
printf 'toolchain rustc %s\n' "$*" >> "$RUST_LOG"
EOF
cat >"$RUST_TOOLCHAIN_BIN/cargo" <<'EOF'
#!/bin/bash
printf 'toolchain cargo %s\n' "$*" >> "$RUST_LOG"
EOF
cat >"$RUST_HOMEBREW_PREFIX/bin/rust-analyzer" <<'EOF'
#!/bin/bash
rustc_path="$(command -v rustc || true)"
cargo_path="$(command -v cargo || true)"
if [ "$rustc_path" != "$RUST_TOOLCHAIN_BIN/rustc" ] || [ "$cargo_path" != "$RUST_TOOLCHAIN_BIN/cargo" ]; then
  printf 'rust-analyzer wrapper did not expose mise Rust tools\n' >&2
  exit 1
fi
printf 'rust-analyzer %s\n' "$*" >> "$RUST_LOG"
EOF
chmod +x \
    "$RUST_BIN/mise" \
    "$RUST_BIN/brew" \
    "$RUST_TOOLCHAIN_BIN/rustc" \
    "$RUST_TOOLCHAIN_BIN/cargo" \
    "$RUST_HOMEBREW_PREFIX/bin/rust-analyzer"

HOME="$RUST_HOME" PATH="$RUST_BIN:/usr/bin:/bin" RUST_LOG="$RUST_LOG" RUST_HOMEBREW_PREFIX="$RUST_HOMEBREW_PREFIX" RUST_TOOLCHAIN_BIN="$RUST_TOOLCHAIN_BIN" bash "$REPO_ROOT/setup/languages/rust.sh" >/dev/null
test ! -e "$RUST_HOME/.local/bin/rust-analyzer"
grep -q 'mise install rust' "$RUST_LOG"
grep -q 'mise exec -- rustc --version' "$RUST_LOG"

XML_HOME="$TMP_DIR/xml-home"
XML_BIN="$TMP_DIR/xml-bin"
XML_LOG="$TMP_DIR/xml.log"
XML_JAR_URL='https://repo.eclipse.org/content/repositories/lemminx-releases/org/eclipse/lemminx/org.eclipse.lemminx/0.31.1/org.eclipse.lemminx-0.31.1-uber.jar'
XML_EXPECTED_SHA1='1d65f934e0dc1bdde082b77ffda6d1081b90a0c3'
mkdir -p "$XML_HOME" "$XML_BIN"
cat >"$XML_BIN/java" <<'EOF'
#!/bin/bash
printf 'java %s\n' "$*" >> "$XML_LOG"
exit 0
EOF
cat >"$XML_BIN/mise" <<'EOF'
#!/bin/bash
printf 'mise %s\n' "$*" >> "$XML_LOG"
if [ "${1:-}" = "exec" ] && [ "${2:-}" = "--" ]; then
  shift 2
  printf '%s\n' "$*" >> "$XML_LOG"
fi
exit 0
EOF
cat >"$XML_BIN/curl" <<'EOF'
#!/bin/bash
output=""
url=""
while [ $# -gt 0 ]; do
  case "$1" in
    -o)
      output="$2"
      shift 2
      ;;
    -*)
      shift
      ;;
    *)
      url="$1"
      shift
      ;;
  esac
done
printf 'curl %s\n' "$url" >> "$XML_LOG"
if [ -z "$output" ]; then
  exit 1
fi
case "$url" in
  *.sha1)
    printf '%s\n' "$XML_EXPECTED_SHA1" > "$output"
    ;;
  *)
    printf 'fake lemminx jar\n' > "$output"
    ;;
esac
EOF
cat >"$XML_BIN/shasum" <<'EOF'
#!/bin/bash
if [ "$1" = "-a" ] && [ "$2" = "1" ]; then
  printf '%s  %s\n' "$XML_EXPECTED_SHA1" "$3"
  exit 0
fi
exit 1
EOF
chmod +x "$XML_BIN/java" "$XML_BIN/curl" "$XML_BIN/shasum" "$XML_BIN/mise"

HOME="$XML_HOME" PATH="$XML_BIN:/usr/bin:/bin" XML_LOG="$XML_LOG" XML_EXPECTED_SHA1="$XML_EXPECTED_SHA1" bash "$REPO_ROOT/setup/languages/xml.sh" >/dev/null
[ -s "$XML_HOME/.local/share/lemminx/lemminx.jar" ]
[ ! -e "$XML_HOME/.local/bin/lemminx" ]
grep -q "curl $XML_JAR_URL" "$XML_LOG"
grep -q "curl $XML_JAR_URL.sha1" "$XML_LOG"

SOLANA_HOME="$TMP_DIR/solana-home"
SOLANA_BIN="$TMP_DIR/solana-bin"
SOLANA_LOG="$TMP_DIR/solana.log"
mkdir -p "$SOLANA_HOME" "$SOLANA_BIN"
cat >"$SOLANA_BIN/mise" <<'EOF'
#!/bin/bash
printf 'mise %s\n' "$*" >> "$SOLANA_LOG"
if [ "${1:-}" = "exec" ] && [ "${2:-}" = "--" ]; then
  shift 2
  printf '%s\n' "$*" >> "$SOLANA_LOG"
  if [ "${1:-}" = "cargo" ] && [ "${2:-}" = "install" ]; then
    mkdir -p "$HOME/.cargo/bin"
    cat > "$HOME/.cargo/bin/avm" <<'AVMEOF'
#!/bin/bash
printf 'avm %s\n' "$*" >> "$SOLANA_LOG"
case "${1:-}" in
  install)
    mkdir -p "$HOME/.avm/bin"
    cat > "$HOME/.avm/bin/anchor" <<'ANCHOREEOF'
#!/bin/bash
printf 'anchor %s\n' "$*" >> "$SOLANA_LOG"
if [ "${1:-}" = "--version" ]; then
  printf 'anchor-cli 0.31.1\n'
fi
ANCHOREEOF
    chmod +x "$HOME/.avm/bin/anchor"
    ;;
esac
exit 0
AVMEOF
    chmod +x "$HOME/.cargo/bin/avm"
  fi
fi
exit 0
EOF
cat >"$SOLANA_BIN/curl" <<'EOF'
#!/bin/bash
output=""
url=""
while [ $# -gt 0 ]; do
  case "$1" in
    -o)
      output="$2"
      shift 2
      ;;
    -*)
      shift
      ;;
    *)
      url="$1"
      shift
      ;;
  esac
done
printf 'curl %s\n' "$url" >> "$SOLANA_LOG"
if [ -z "$output" ]; then
  exit 1
fi
cat > "$output" <<'INSTALLEREOF'
#!/bin/sh
set -eu

printf 'agave installer\n' >> "$SOLANA_LOG"
mkdir -p "$HOME/.local/share/solana/install/active_release/bin"
cat > "$HOME/.local/share/solana/install/active_release/bin/solana" <<'SOLANAEOF'
#!/bin/bash
printf 'solana %s\n' "$*" >> "$SOLANA_LOG"
if [ "${1:-}" = "--version" ]; then
  printf 'solana-cli 2.0.0\n'
fi
SOLANAEOF
cat > "$HOME/.local/share/solana/install/active_release/bin/agave-install" <<'AGAVEEOF'
#!/bin/bash
printf 'agave-install %s\n' "$*" >> "$SOLANA_LOG"
AGAVEEOF
cat > "$HOME/.local/share/solana/install/active_release/bin/cargo-build-sbf" <<'CARGOBUILDSBFEOF'
#!/bin/bash
printf 'cargo-build-sbf %s\n' "$*" >> "$SOLANA_LOG"
if [ "${1:-}" = "--version" ]; then
  printf 'cargo-build-sbf 2.0.0\n'
fi
CARGOBUILDSBFEOF
chmod +x \
  "$HOME/.local/share/solana/install/active_release/bin/solana" \
  "$HOME/.local/share/solana/install/active_release/bin/agave-install" \
  "$HOME/.local/share/solana/install/active_release/bin/cargo-build-sbf"
INSTALLEREOF
EOF
chmod +x "$SOLANA_BIN/mise" "$SOLANA_BIN/curl"

ANCHOR_VERSION="0.31.1" HOME="$SOLANA_HOME" CARGO_HOME="$SOLANA_HOME/.cargo" AVM_HOME="$SOLANA_HOME/.avm" PATH="$SOLANA_BIN:/usr/bin:/bin" SOLANA_LOG="$SOLANA_LOG" bash "$REPO_ROOT/setup/blockchain/solana.sh" >/dev/null
[ -x "$SOLANA_HOME/.local/bin/solana" ]
[ -x "$SOLANA_HOME/.local/bin/agave-install" ]
[ -x "$SOLANA_HOME/.local/bin/cargo-build-sbf" ]
[ -x "$SOLANA_HOME/.local/bin/avm" ]
[ -x "$SOLANA_HOME/.local/bin/anchor" ]
grep -q 'mise install rust' "$SOLANA_LOG"
grep -q 'mise exec -- rustc --version' "$SOLANA_LOG"
grep -q 'curl https://release.anza.xyz/stable/install' "$SOLANA_LOG"
grep -q 'agave installer' "$SOLANA_LOG"
grep -q 'cargo install --git https://github.com/solana-foundation/anchor avm --force' "$SOLANA_LOG"
grep -q 'avm install 0.31.1' "$SOLANA_LOG"
grep -q 'avm use 0.31.1' "$SOLANA_LOG"
HOME="$SOLANA_HOME" CARGO_HOME="$SOLANA_HOME/.cargo" AVM_HOME="$SOLANA_HOME/.avm" PATH="$SOLANA_BIN:/usr/bin:/bin" SOLANA_LOG="$SOLANA_LOG" "$SOLANA_HOME/.local/bin/solana" --version >/dev/null
HOME="$SOLANA_HOME" CARGO_HOME="$SOLANA_HOME/.cargo" AVM_HOME="$SOLANA_HOME/.avm" PATH="$SOLANA_BIN:/usr/bin:/bin" SOLANA_LOG="$SOLANA_LOG" "$SOLANA_HOME/.local/bin/agave-install" update >/dev/null
HOME="$SOLANA_HOME" CARGO_HOME="$SOLANA_HOME/.cargo" AVM_HOME="$SOLANA_HOME/.avm" PATH="$SOLANA_BIN:/usr/bin:/bin" SOLANA_LOG="$SOLANA_LOG" "$SOLANA_HOME/.local/bin/cargo-build-sbf" --version >/dev/null
HOME="$SOLANA_HOME" CARGO_HOME="$SOLANA_HOME/.cargo" AVM_HOME="$SOLANA_HOME/.avm" PATH="$SOLANA_BIN:/usr/bin:/bin" SOLANA_LOG="$SOLANA_LOG" "$SOLANA_HOME/.local/bin/avm" --version >/dev/null
HOME="$SOLANA_HOME" CARGO_HOME="$SOLANA_HOME/.cargo" AVM_HOME="$SOLANA_HOME/.avm" PATH="$SOLANA_BIN:/usr/bin:/bin" SOLANA_LOG="$SOLANA_LOG" "$SOLANA_HOME/.local/bin/anchor" --version >/dev/null
grep -q 'solana --version' "$SOLANA_LOG"
grep -q 'agave-install update' "$SOLANA_LOG"
grep -q 'cargo-build-sbf --version' "$SOLANA_LOG"
grep -q 'avm --version' "$SOLANA_LOG"
grep -q 'anchor --version' "$SOLANA_LOG"

: >"$SOLANA_LOG"
HOME="$SOLANA_HOME" CARGO_HOME="$SOLANA_HOME/.cargo" AVM_HOME="$SOLANA_HOME/.avm" PATH="$SOLANA_BIN:/usr/bin:/bin" SOLANA_LOG="$SOLANA_LOG" bash "$REPO_ROOT/setup/blockchain/solana.sh" >/dev/null
grep -q 'agave-install update' "$SOLANA_LOG"
if grep -q 'curl https://release.anza.xyz/stable/install' "$SOLANA_LOG"; then
    printf 'solana installer should prefer agave-install update when active release exists\n' >&2
    exit 1
fi

DOCTOR_HOME="$TMP_DIR/doctor-home"
DOCTOR_BIN="$TMP_DIR/doctor-bin"
mkdir -p "$DOCTOR_HOME" "$DOCTOR_BIN"
cat >"$DOCTOR_BIN/git" <<'EOF'
#!/bin/bash
exit 0
EOF
cat >"$DOCTOR_BIN/bash" <<'EOF'
#!/bin/bash
exec /bin/bash "$@"
EOF
cat >"$DOCTOR_BIN/uname" <<'EOF'
#!/bin/bash
printf 'Darwin\n'
EOF
chmod +x "$DOCTOR_BIN/git" "$DOCTOR_BIN/bash" "$DOCTOR_BIN/uname"
DOCTOR_OUTPUT="$(HOME="$DOCTOR_HOME" PATH="$DOCTOR_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/doctor.sh")"
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'brew missing — run ./setup.sh bootstrap before brew-managed setup'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'mise missing — run ./setup.sh brew-packages before runtime setup'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'ruff missing; run ./setup.sh python'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'biome missing; run ./setup.sh typescript'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'jdtls missing; run ./setup.sh java'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'kotlin-language-server missing; run ./setup.sh kotlin'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'pyright-langserver missing; run ./setup.sh python'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'bash-language-server missing; run ./setup.sh brew-packages'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'Doctor completed'

CLEAN_HOME="$TMP_DIR/clean-home"
mkdir -p "$CLEAN_HOME/.config/zed"
cp "$REPO_ROOT/home/dot_zshrc" "$CLEAN_HOME/.zshrc"
cp "$REPO_ROOT/home/dot_config/zed/settings.json" "$CLEAN_HOME/.config/zed/settings.json"
printf 'old zshrc\n' >"$CLEAN_HOME/.zshrc.backup.20260101-010101"
printf 'old zed settings\n' >"$CLEAN_HOME/.config/zed/settings.json.backup.20260101-010101"
printf 'keep unrelated\n' >"$CLEAN_HOME/.config/zed/settings.json.backup.not-managed"
HOME="$CLEAN_HOME" SETUP_YES=1 SETUP_NO_INPUT=1 bash "$REPO_ROOT/setup/clean-backups.sh" >/dev/null
[ ! -e "$CLEAN_HOME/.zshrc.backup.20260101-010101" ]
[ ! -e "$CLEAN_HOME/.config/zed/settings.json.backup.20260101-010101" ]
[ -e "$CLEAN_HOME/.config/zed/settings.json.backup.not-managed" ]

bash "$REPO_ROOT/setup/languages/go.sh" >/dev/null
bash "$REPO_ROOT/setup/languages/node.sh" >/dev/null
bash "$REPO_ROOT/setup/languages/bun.sh" >/dev/null

cmp -s "$REPO_ROOT/home/dot_config/mise/config.toml" "$FAKE_HOME/.config/mise/config.toml"

GO_SETUP_OUTPUT="$($SETUP_SH --yes go)"
if printf '%s' "$GO_SETUP_OUTPUT" | grep -q 'Activate Gno support in Zed'; then
    printf 'go command should not print Zed Gno activation next step\n' >&2
    exit 1
fi

APPS_HOME="$TMP_DIR/apps-home"
APPS_ZSH_CUSTOM="$APPS_HOME/.oh-my-zsh/custom"
mkdir -p \
    "$APPS_ZSH_CUSTOM/plugins/zsh-autosuggestions" \
    "$APPS_ZSH_CUSTOM/plugins/zsh-syntax-highlighting" \
    "$APPS_ZSH_CUSTOM/plugins/zsh-completions" \
    "$APPS_ZSH_CUSTOM/plugins/zsh-hangul" \
    "$APPS_ZSH_CUSTOM/themes/spaceship-prompt" \
    "$APPS_HOME/.local/share/zed/dev-extensions/zed-gno"
touch "$APPS_HOME/.local/share/zed/dev-extensions/zed-gno/extension.toml"
APPS_SETUP_OUTPUT="$(HOME="$APPS_HOME" ZSH_CUSTOM="$APPS_ZSH_CUSTOM" PATH="$FAKE_BIN:/usr/bin:/bin" "$SETUP_SH" --yes apps)"
printf '%s' "$APPS_SETUP_OUTPUT" | grep -q 'Activate Gno support in Zed'

grep -q 'go env -w GOBIN=' "$LOG_FILE"
grep -q 'go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0' "$LOG_FILE"
grep -q 'go install golang.org/x/tools/gopls@latest' "$LOG_FILE"
grep -q 'go install mvdan.cc/gofumpt@latest' "$LOG_FILE"
test ! -e "$FAKE_HOME/.local/bin/gopls"
test ! -e "$FAKE_HOME/.local/bin/golangci-lint"
test ! -e "$FAKE_HOME/.local/bin/gofumpt"

grep -q 'corepack enable pnpm' "$LOG_FILE"
grep -q 'corepack install --global pnpm@latest-10' "$LOG_FILE"
grep -q 'pnpm --version' "$LOG_FILE"

if grep -q 'bun install -g' "$LOG_FILE"; then
    printf 'languages/bun.sh should not install Bun packages\n' >&2
    exit 1
fi

: >"$LOG_FILE"

PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/blockchain/gno.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/typescript.sh" >/dev/null

grep -q 'go env -w GOBIN=' "$LOG_FILE"
grep -q 'go install github.com/gnolang/gno/gnovm/cmd/gno@latest' "$LOG_FILE"
grep -q 'go install github.com/gnoverse/gnopls@latest' "$LOG_FILE"
test ! -e "$FAKE_HOME/.local/bin/gno"
test ! -e "$FAKE_HOME/.local/bin/gnopls"
grep -q 'bun install -g typescript' "$LOG_FILE"
grep -q 'bun install -g typescript-language-server' "$LOG_FILE"
test ! -e "$FAKE_HOME/.local/bin/typescript-language-server"

: >"$LOG_FILE"
rm -f "$FAKE_BIN/go" "$FAKE_BIN/bun"
mkdir -p "$TMP_DIR/fake-go-prefix/bin" "$FAKE_HOME/.bun/bin"

cat >"$TMP_DIR/fake-go-prefix/bin/go" <<EOF
#!/bin/bash
printf 'go %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "version" ]; then
  printf 'go version go1.25.6 darwin/arm64\n'
fi
EOF

cat >"$FAKE_BIN/brew" <<EOF
#!/bin/bash
if [ "\${1:-}" = "list" ]; then
  exit 0
fi
if [ "\${1:-}" = "--prefix" ] && [ "\${2:-}" = "go@1.25" ]; then
  printf '%s\n' "$TMP_DIR/fake-go-prefix"
  exit 0
fi
if [ "\${1:-}" = "--prefix" ]; then
  printf '%s\n' "$TMP_DIR/fake-homebrew"
  exit 0
fi
printf 'brew %s\n' "\$*" >> "$LOG_FILE"
EOF

cat >"$FAKE_HOME/.bun/bin/bun" <<EOF
#!/bin/bash
printf 'bun %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "--version" ]; then
  printf '1.2.0\n'
fi
EOF

cat >"$FAKE_HOME/.bun/bin/bunx" <<EOF
#!/bin/bash
printf 'bunx %s\n' "\$*" >> "$LOG_FILE"
EOF

chmod +x "$TMP_DIR/fake-go-prefix/bin/go" "$FAKE_HOME/.bun/bin/bun" "$FAKE_HOME/.bun/bin/bunx" "$FAKE_BIN/brew"

PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/go.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/blockchain/gno.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/typescript.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/apps/opencode.sh" >/dev/null

grep -q 'go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0' "$LOG_FILE"
grep -q 'go install golang.org/x/tools/gopls@latest' "$LOG_FILE"
grep -q 'go install github.com/gnolang/gno/gnovm/cmd/gno@latest' "$LOG_FILE"
grep -q 'bun install -g typescript' "$LOG_FILE"
grep -q 'bun install -g opencode-ai' "$LOG_FILE"
grep -q 'bunx oh-my-openagent install --no-tui --claude=no --openai=yes --gemini=no --copilot=no' "$LOG_FILE"

BOOTSTRAP_HOME="$TMP_DIR/bootstrap-home"
BOOTSTRAP_BIN="$TMP_DIR/bootstrap-bin"
BOOTSTRAP_PREFIX="$TMP_DIR/fake-homebrew"
BOOTSTRAP_LOG="$TMP_DIR/bootstrap.log"

mkdir -p "$BOOTSTRAP_HOME" "$BOOTSTRAP_BIN" "$BOOTSTRAP_PREFIX/bin"

cat >"$BOOTSTRAP_BIN/curl" <<'EOF'
#!/bin/bash
cat <<'SCRIPT'
mkdir -p "$HOMEBREW_PREFIX/bin"
cat > "$HOMEBREW_PREFIX/bin/brew" <<'BREWEOF'
#!/bin/bash
if [ "${1:-}" = "shellenv" ]; then
  printf 'export PATH="%s/bin:$PATH"\n' "$HOMEBREW_PREFIX"
  exit 0
fi
printf 'brew %s\n' "$*" >> "$BOOTSTRAP_LOG"
BREWEOF
chmod +x "$HOMEBREW_PREFIX/bin/brew"
SCRIPT
EOF

cat >"$BOOTSTRAP_BIN/bash" <<'EOF'
#!/bin/bash
if [ "$1" = "-c" ]; then
  shift
  eval "$1"
  exit $?
fi
exec /bin/bash "$@"
EOF

chmod +x "$BOOTSTRAP_BIN/curl" "$BOOTSTRAP_BIN/bash"

env -i HOME="$BOOTSTRAP_HOME" PATH="$BOOTSTRAP_BIN:/usr/bin:/bin" HOMEBREW_PREFIX="$BOOTSTRAP_PREFIX" BOOTSTRAP_LOG="$BOOTSTRAP_LOG" bash "$REPO_ROOT/setup/commands/10-bootstrap" >/dev/null

# shellcheck disable=SC2016
grep -q 'eval "$(brew shellenv)"' "$BOOTSTRAP_HOME/.zprofile"

[ ! -e "$REPO_ROOT/link.sh" ]
grep -q 'setup/link.sh' "$REPO_ROOT/setup/commands/40-links"
# shellcheck disable=SC2016
grep -q 'eval "$(brew shellenv)"' "$REPO_ROOT/setup/commands/10-bootstrap"
grep -q 'SETUP_SKIP_COMMANDS' "$REPO_ROOT/setup/commands/30-languages"
grep -q 'SETUP_SKIP_COMMANDS' "$REPO_ROOT/setup/commands/35-blockchain"
[ ! -e "$REPO_ROOT/setup/commands/35-tool-packages" ]
[ ! -e "$REPO_ROOT/setup/packages/go.sh" ]
[ ! -e "$REPO_ROOT/setup/packages/bun.sh" ]
[ ! -e "$REPO_ROOT/.gitconfig" ]
[ ! -e "$REPO_ROOT/.gitconfig.override.example" ]
[ ! -e "$REPO_ROOT/.gitignore_global" ]
[ ! -e "$REPO_ROOT/.zshrc" ]
[ ! -e "$REPO_ROOT/.config/AGENTS.md" ]
[ ! -e "$REPO_ROOT/.config/gh/config.yml" ]
[ ! -e "$REPO_ROOT/.config/karabiner/karabiner.json" ]
[ ! -e "$REPO_ROOT/.config/nvim/init.lua" ]
[ ! -e "$REPO_ROOT/.config/nvim/lua/config/lazy.lua" ]
[ ! -e "$REPO_ROOT/.config/nvim/lua/config/options.lua" ]
[ ! -e "$REPO_ROOT/.config/opencode/oh-my-openagent.json" ]
[ ! -e "$REPO_ROOT/.config/opencode/opencode.json" ]
[ ! -e "$REPO_ROOT/.config/opencode/tui.json" ]
[ ! -e "$REPO_ROOT/.config/zed/settings.json" ]
[ -e "$REPO_ROOT/docs/gitconfig.override.example" ]
grep -q 'karabiner-elements' "$REPO_ROOT/setup/commands/55-karabiner"
grep -q 'KeyRepeat' "$REPO_ROOT/setup/commands/60-macos"
if grep -q 'KeyRepeat' "$REPO_ROOT/setup/commands/55-karabiner"; then
    printf 'karabiner command should not apply macOS keyboard defaults\n' >&2
    exit 1
fi
grep -q 'home' "$REPO_ROOT/.chezmoiroot"
grep -q 'brew "chezmoi"' "$REPO_ROOT/Brewfile"
grep -q 'chezmoi --source' "$REPO_ROOT/setup/link.sh"
grep -q 'HOMEBREW_PREFIX' "$REPO_ROOT/home/dot_zshrc"
grep -q 'brew "mise"' "$REPO_ROOT/Brewfile"
grep -q 'go env -w GOBIN="\$HOME/.local/bin"' "$REPO_ROOT/.github/workflows/ci.yml"
if grep -q 'go env GOPATH' "$REPO_ROOT/.github/workflows/ci.yml"; then
    printf 'CI should not add GOPATH/bin to PATH\n' >&2
    exit 1
fi
grep -q 'setup/blockchain/\*.sh' "$REPO_ROOT/.github/workflows/ci.yml"
if grep -q 'mise install' "$REPO_ROOT/setup/commands/20-brew-packages"; then
    printf 'brew-packages should not run mise install directly\n' >&2
    exit 1
fi
grep -q 'mise install go' "$REPO_ROOT/setup/languages/go.sh"
grep -q 'configure_mise_go_bin' "$REPO_ROOT/setup/languages/go.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/languages/go.sh"
grep -q 'mise install node' "$REPO_ROOT/setup/languages/node.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/languages/node.sh"
grep -q 'COREPACK_ENABLE_DOWNLOAD_PROMPT=0 mise exec -- corepack enable pnpm' "$REPO_ROOT/setup/languages/node.sh"
grep -q 'corepack install --global pnpm@latest-10' "$REPO_ROOT/setup/languages/node.sh"
grep -q 'mise install bun' "$REPO_ROOT/setup/languages/bun.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/languages/bun.sh"
grep -q "chezmoi --source \"\$DOTFILES_DIR\" --no-tty --force apply --dry-run --verbose" "$REPO_ROOT/setup/check.sh"
grep -q 'mise install java' "$REPO_ROOT/setup/languages/java.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/languages/java.sh"
grep -q 'mise install java' "$REPO_ROOT/setup/languages/kotlin.sh"
grep -q 'mise install kotlin' "$REPO_ROOT/setup/languages/kotlin.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/languages/kotlin.sh"
grep -q 'mise install python' "$REPO_ROOT/setup/languages/python.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/languages/python.sh"
grep -q 'mise install rust' "$REPO_ROOT/setup/languages/rust.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/languages/rust.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/languages/xml.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/languages/typescript.sh"
grep -q 'mise install go' "$REPO_ROOT/setup/blockchain/gno.sh"
grep -q 'configure_mise_go_bin' "$REPO_ROOT/setup/blockchain/gno.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/blockchain/gno.sh"
grep -q 'github.com/gnolang/gno/gnovm/cmd/gno@latest' "$REPO_ROOT/setup/blockchain/gno.sh"
if grep -q 'create_mise_go_tool_wrapper' "$REPO_ROOT/setup/lib/common.sh" "$REPO_ROOT/setup/languages/go.sh" "$REPO_ROOT/setup/blockchain/gno.sh"; then
    printf 'Go tooling should be managed by mise without custom wrappers\n' >&2
    exit 1
fi
if grep -q 'create_.*wrapper' "$REPO_ROOT/setup/lib/common.sh" "$REPO_ROOT/setup/languages/rust.sh" "$REPO_ROOT/setup/languages/typescript.sh" "$REPO_ROOT/setup/languages/xml.sh"; then
    printf 'Runtime LSP launch should not rely on generated wrappers\n' >&2
    exit 1
fi
grep -q 'mise install rust' "$REPO_ROOT/setup/blockchain/solana.sh"
grep -q 'sync_mise_global_config' "$REPO_ROOT/setup/blockchain/solana.sh"
grep -q 'https://release.anza.xyz/stable/install' "$REPO_ROOT/setup/blockchain/solana.sh"
grep -q 'https://github.com/solana-foundation/anchor avm --force' "$REPO_ROOT/setup/blockchain/solana.sh"
grep -q 'mise runtime config found' "$REPO_ROOT/setup/doctor.sh"
grep -q 'mise global runtime config found' "$REPO_ROOT/setup/doctor.sh"
grep -q 'mise activate zsh' "$REPO_ROOT/home/dot_zshrc"
grep -q 'Global defaults are tracked in ~/.config/mise/config.toml' "$REPO_ROOT/home/dot_zshrc"
cmp -s "$REPO_ROOT/mise.toml" "$REPO_ROOT/home/dot_config/mise/config.toml"
grep -q 'cask "brave-browser"' "$REPO_ROOT/Brewfile"
grep -q 'PLAYWRIGHT_MCP_EXECUTABLE_PATH' "$REPO_ROOT/home/dot_zshrc"
if grep -q 'kaku' "$REPO_ROOT/home/dot_zshrc"; then
    printf 'home/dot_zshrc should not reference kaku\n' >&2
    exit 1
fi
