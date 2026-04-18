#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

FAKE_HOME="$TMP_DIR/home"
FAKE_BIN="$TMP_DIR/bin"
LOG_FILE="$TMP_DIR/commands.log"

mkdir -p "$FAKE_HOME" "$FAKE_BIN"

cat > "$FAKE_BIN/go" <<EOF
#!/bin/bash
printf 'go %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "version" ]; then
  printf 'go version go1.25.6 darwin/arm64\n'
fi
EOF

cat > "$FAKE_BIN/bun" <<EOF
#!/bin/bash
printf 'bun %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "--version" ]; then
  printf '1.2.0\n'
fi
EOF

cat > "$FAKE_BIN/curl" <<EOF
#!/bin/bash
printf 'curl %s\n' "\$*" >> "$LOG_FILE"
exit 0
EOF

cat > "$FAKE_BIN/brew" <<EOF
#!/bin/bash
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

chmod +x "$FAKE_BIN/go" "$FAKE_BIN/bun" "$FAKE_BIN/curl" "$FAKE_BIN/brew"

export HOME="$FAKE_HOME"
export PATH="$FAKE_BIN:$PATH"

HELP_OUTPUT="$($REPO_ROOT/setup.sh --help)"
printf '%s' "$HELP_OUTPUT" | grep -q 'tool-packages'

bash "$REPO_ROOT/setup/languages/go.sh" >/dev/null
bash "$REPO_ROOT/setup/languages/bun.sh" >/dev/null

if grep -q 'go install' "$LOG_FILE"; then
  printf 'languages/go.sh should not install Go tools\n' >&2
  exit 1
fi

if grep -q 'bun install -g' "$LOG_FILE"; then
  printf 'languages/bun.sh should not install Bun packages\n' >&2
  exit 1
fi

: > "$LOG_FILE"

bash "$REPO_ROOT/setup/commands/35-tool-packages" >/dev/null

grep -q 'go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0' "$LOG_FILE"
grep -q 'go install mvdan.cc/gofumpt@latest' "$LOG_FILE"
grep -q 'go install github.com/gnolang/gno/gnovm/cmd/gno@latest' "$LOG_FILE"
grep -q 'go install github.com/gnoverse/gnopls@latest' "$LOG_FILE"
grep -q 'bun install -g opencode-ai' "$LOG_FILE"
grep -q 'bun install -g oh-my-openagent' "$LOG_FILE"
grep -q 'bun install -g typescript' "$LOG_FILE"
grep -q 'bun install -g typescript-language-server' "$LOG_FILE"

: > "$LOG_FILE"
rm -f "$FAKE_BIN/go" "$FAKE_BIN/bun"
mkdir -p "$TMP_DIR/fake-go-prefix/bin" "$FAKE_HOME/.bun/bin"

cat > "$TMP_DIR/fake-go-prefix/bin/go" <<EOF
#!/bin/bash
printf 'go %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "version" ]; then
  printf 'go version go1.25.6 darwin/arm64\n'
fi
EOF

cat > "$FAKE_HOME/.bun/bin/bun" <<EOF
#!/bin/bash
printf 'bun %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "--version" ]; then
  printf '1.2.0\n'
fi
EOF

cat > "$FAKE_HOME/.bun/bin/bunx" <<EOF
#!/bin/bash
printf 'bunx %s\n' "\$*" >> "$LOG_FILE"
EOF

chmod +x "$TMP_DIR/fake-go-prefix/bin/go" "$FAKE_HOME/.bun/bin/bun" "$FAKE_HOME/.bun/bin/bunx"

PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/go.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/packages/go.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/packages/bun.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/apps/opencode.sh" >/dev/null

grep -q 'go version' "$LOG_FILE"
grep -q 'go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0' "$LOG_FILE"
grep -q 'bun install -g opencode-ai' "$LOG_FILE"
grep -q 'bunx oh-my-openagent install --no-tui --claude=no --openai=yes --gemini=no --copilot=no' "$LOG_FILE"

BOOTSTRAP_HOME="$TMP_DIR/bootstrap-home"
BOOTSTRAP_BIN="$TMP_DIR/bootstrap-bin"
BOOTSTRAP_PREFIX="$TMP_DIR/fake-homebrew"
BOOTSTRAP_LOG="$TMP_DIR/bootstrap.log"

mkdir -p "$BOOTSTRAP_HOME" "$BOOTSTRAP_BIN" "$BOOTSTRAP_PREFIX/bin"

cat > "$BOOTSTRAP_BIN/curl" <<'EOF'
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

cat > "$BOOTSTRAP_BIN/bash" <<'EOF'
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

grep -q 'eval "$(brew shellenv)"' "$BOOTSTRAP_HOME/.zprofile"

[ ! -e "$REPO_ROOT/link.sh" ]
grep -q 'setup/link.sh' "$REPO_ROOT/setup/commands/40-links"
grep -q 'eval "$(brew shellenv)"' "$REPO_ROOT/setup/commands/10-bootstrap"
grep -q 'HOMEBREW_PREFIX' "$REPO_ROOT/.zshrc"
if grep -q 'kaku' "$REPO_ROOT/.zshrc"; then
  printf '.zshrc should not reference kaku\n' >&2
  exit 1
fi
