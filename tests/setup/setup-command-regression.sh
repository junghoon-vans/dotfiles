#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETUP_SH="$REPO_ROOT/setup.sh"
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

cat > "$FAKE_BIN/mise" <<EOF
#!/bin/bash
printf 'mise %s\n' "\$*" >> "$LOG_FILE"
if [ "\${1:-}" = "install" ] && [ "\${2:-}" = "--dry-run-code" ]; then
  exit 1
fi
exit 0
EOF

chmod +x "$FAKE_BIN/go" "$FAKE_BIN/bun" "$FAKE_BIN/curl" "$FAKE_BIN/brew" "$FAKE_BIN/mise"

export HOME="$FAKE_HOME"
export PATH="$FAKE_BIN:$PATH"

HELP_OUTPUT="$($SETUP_SH --help)"
printf '%s' "$HELP_OUTPUT" | grep -q 'opencode'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install OpenCode and bootstrap oh-my-openagent'
printf '%s' "$HELP_OUTPUT" | grep -q 'Inspect host prerequisites'
printf '%s' "$HELP_OUTPUT" | grep -q 'Remove managed dotfile backup files created before chezmoi apply'
printf '%s' "$HELP_OUTPUT" | grep -q 'Language commands:'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install Go, gopls, and Go formatter/linter tools'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install TypeScript, TypeScript LSP, and Biome'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install Gno CLI and gnopls using Go'
printf '%s' "$HELP_OUTPUT" | grep -q 'Install Eclipse LemMinX XML language server'
printf '%s' "$HELP_OUTPUT" | grep -q 'Requires Go; run ./setup.sh go first on a clean host'
printf '%s' "$HELP_OUTPUT" | grep -q 'Requires Java; run ./setup.sh java first on a clean host'
printf '%s' "$HELP_OUTPUT" | grep -q 'Requires Bun; run ./setup.sh bun first on a clean host'
printf '%s' "$HELP_OUTPUT" | grep -q -- '--yes'
printf '%s' "$HELP_OUTPUT" | grep -q -- '--no-input'
printf '%s' "$HELP_OUTPUT" | grep -q -- '--dry-run'
printf '%s' "$HELP_OUTPUT" | grep -q -- '--skip COMMAND'

while IFS= read -r language_name; do
  LANGUAGE_COMMAND_OUTPUT="$($SETUP_SH --dry-run "$language_name")"
  printf '%s' "$LANGUAGE_COMMAND_OUTPUT" | grep -q "^  ${language_name}[[:space:]]"
  grep -Eq "(^|[[:space:]])${language_name}([[:space:];]|$)" "$REPO_ROOT/setup/commands/30-languages"
done < <(for path in "$REPO_ROOT"/setup/languages/*.sh; do basename "${path%.sh}"; done | sort)

EXPECTED_LANGUAGE_ORDER="go node bun java xml rust python gno typescript"
ACTUAL_LANGUAGE_ORDER="$(grep '^for language_name in ' "$REPO_ROOT/setup/commands/30-languages" | sed 's/^for language_name in //; s/; do$//')"
if [ "$ACTUAL_LANGUAGE_ORDER" != "$EXPECTED_LANGUAGE_ORDER" ]; then
  printf 'languages umbrella order changed: expected "%s", got "%s"\n' "$EXPECTED_LANGUAGE_ORDER" "$ACTUAL_LANGUAGE_ORDER" >&2
  exit 1
fi

LANGUAGE_PROMPT_SETUP_DIR="$TMP_DIR/language-prompt-setup"
LANGUAGE_PROMPT_LOG="$TMP_DIR/language-prompt.log"
mkdir -p "$LANGUAGE_PROMPT_SETUP_DIR/languages"
for language_name in $EXPECTED_LANGUAGE_ORDER; do
  cat > "$LANGUAGE_PROMPT_SETUP_DIR/languages/$language_name.sh" <<'EOF'
#!/bin/bash
printf '%s\n' "$(basename "$0")" >> "$LANGUAGE_PROMPT_LOG"
EOF
  chmod +x "$LANGUAGE_PROMPT_SETUP_DIR/languages/$language_name.sh"
done

LANGUAGE_PROMPT_OUTPUT="$(SETUP_DIR="$LANGUAGE_PROMPT_SETUP_DIR" SETUP_YES=1 SETUP_NO_INPUT=1 LANGUAGE_PROMPT_LOG="$LANGUAGE_PROMPT_LOG" bash "$REPO_ROOT/setup/commands/30-languages")"
printf '%s' "$LANGUAGE_PROMPT_OUTPUT" | grep -q "Run language command 'go'? \[Y/n\] yes (--yes)"
printf '%s' "$LANGUAGE_PROMPT_OUTPUT" | grep -q "Run language command 'xml'? \[Y/n\] yes (--yes)"
read -r -a expected_languages <<< "$EXPECTED_LANGUAGE_ORDER"
EXPECTED_LANGUAGE_RUNS="$(printf '%s.sh\n' "${expected_languages[@]}")"
ACTUAL_LANGUAGE_RUNS="$(cat "$LANGUAGE_PROMPT_LOG")"
if [ "$ACTUAL_LANGUAGE_RUNS" != "$EXPECTED_LANGUAGE_RUNS" ]; then
  printf 'languages umbrella run order changed: expected "%s", got "%s"\n' "$EXPECTED_LANGUAGE_RUNS" "$ACTUAL_LANGUAGE_RUNS" >&2
  exit 1
fi

: > "$LANGUAGE_PROMPT_LOG"
LANGUAGE_SKIP_PROMPT_OUTPUT="$(SETUP_DIR="$LANGUAGE_PROMPT_SETUP_DIR" SETUP_YES=1 SETUP_NO_INPUT=1 SETUP_SKIP_COMMANDS=' gno typescript ' LANGUAGE_PROMPT_LOG="$LANGUAGE_PROMPT_LOG" bash "$REPO_ROOT/setup/commands/30-languages")"
printf '%s' "$LANGUAGE_SKIP_PROMPT_OUTPUT" | grep -q 'Skipping language command: gno'
printf '%s' "$LANGUAGE_SKIP_PROMPT_OUTPUT" | grep -q 'Skipping language command: typescript'
if printf '%s' "$LANGUAGE_SKIP_PROMPT_OUTPUT" | grep -q "Run language command 'gno'?"; then
  printf 'skipped language command should not prompt: gno\n' >&2
  exit 1
fi
if grep -q '^gno.sh$\|^typescript.sh$' "$LANGUAGE_PROMPT_LOG"; then
  printf 'skipped language commands should not run\n' >&2
  exit 1
fi

python3 - "$REPO_ROOT/home/dot_config/opencode/opencode.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as config_file:
    config = json.load(config_file)

xml_lsp = config["lsp"]["xml"]
if xml_lsp["command"] != ["lemminx"]:
    raise SystemExit("OpenCode XML LSP command should be lemminx")
if xml_lsp["extensions"] != [".xml", ".xsd", ".xsl", ".xslt", ".svg"]:
    raise SystemExit("OpenCode XML LSP extensions changed")
PY

DRY_RUN_OUTPUT="$($SETUP_SH --dry-run --skip macos)"
printf '%s' "$DRY_RUN_OUTPUT" | grep -q 'Selected setup commands'
printf '%s' "$DRY_RUN_OUTPUT" | grep -q 'languages'
printf '%s' "$DRY_RUN_OUTPUT" | grep -q '^  karabiner[[:space:]]\+Install Karabiner-Elements'
printf '%s' "$DRY_RUN_OUTPUT" | grep -q 'Skipping command: macos'
if printf '%s' "$DRY_RUN_OUTPUT" | grep -q '^  macos[[:space:]]'; then
  printf 'dry-run selected commands should not include skipped macos command\n' >&2
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

LANGUAGE_DRY_RUN_OUTPUT="$($SETUP_SH --dry-run go gno xml typescript python)"
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  go[[:space:]]\+Install Go, gopls'
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  gno[[:space:]]\+Install Gno CLI'
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  xml[[:space:]]\+Install Eclipse LemMinX XML language server'
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  typescript[[:space:]]\+Install TypeScript'
printf '%s' "$LANGUAGE_DRY_RUN_OUTPUT" | grep -q '^  python[[:space:]]\+Install uv, Python'

LANGUAGE_SKIP_OUTPUT="$($SETUP_SH --dry-run --skip gno go gno)"
printf '%s' "$LANGUAGE_SKIP_OUTPUT" | grep -q 'Skipping command: gno'
printf '%s' "$LANGUAGE_SKIP_OUTPUT" | grep -q '^  go[[:space:]]\+Install Go, gopls'
if printf '%s' "$LANGUAGE_SKIP_OUTPUT" | grep -q '^  gno[[:space:]]'; then
  printf 'dry-run selected commands should not include skipped gno command\n' >&2
  exit 1
fi

BREW_PACKAGES_HOME="$TMP_DIR/brew-packages-home"
BREW_PACKAGES_BIN="$TMP_DIR/brew-packages-bin"
BREW_PACKAGES_LOG="$TMP_DIR/brew-packages.log"
mkdir -p "$BREW_PACKAGES_HOME" "$BREW_PACKAGES_BIN"
cat > "$BREW_PACKAGES_BIN/brew" <<'EOF'
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
cat > "$BREW_PACKAGES_BIN/mise" <<'EOF'
#!/bin/bash
printf 'mise %s\n' "$*" >> "$BREW_PACKAGES_LOG"
exit 0
EOF
chmod +x "$BREW_PACKAGES_BIN/brew" "$BREW_PACKAGES_BIN/mise"
BREW_PACKAGES_PATH="$BREW_PACKAGES_BIN:/usr/bin:/bin"
env HOME="$BREW_PACKAGES_HOME" PATH="$BREW_PACKAGES_PATH" BREW_PACKAGES_HOME="$BREW_PACKAGES_HOME" BREW_PACKAGES_LOG="$BREW_PACKAGES_LOG" bash "$REPO_ROOT/setup/commands/20-brew-packages" >/dev/null
grep -q 'brew bundle check' "$BREW_PACKAGES_LOG"
grep -q 'mise install' "$BREW_PACKAGES_LOG"

if DOCTOR_SKIP_OUTPUT="$($SETUP_SH --dry-run --skip doctor doctor 2>&1)"; then
  printf 'skipping the only selected utility command should fail\n' >&2
  exit 1
fi
printf '%s' "$DOCTOR_SKIP_OUTPUT" | grep -q 'All selected commands were skipped: doctor'

NODE_FAIL_HOME="$TMP_DIR/node-fail-home"
NODE_FAIL_BIN="$TMP_DIR/node-fail-bin"
mkdir -p "$NODE_FAIL_HOME" "$NODE_FAIL_BIN"
cat > "$NODE_FAIL_BIN/curl" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$NODE_FAIL_BIN/curl"
NODE_FAIL_OUTPUT="$TMP_DIR/node-fail-output"
if HOME="$NODE_FAIL_HOME" PATH="$NODE_FAIL_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/node.sh" >"$NODE_FAIL_OUTPUT" 2>&1; then
  printf 'node installer should fail when the latest NVM version cannot be detected\n' >&2
  exit 1
fi
grep -q 'Could not determine latest NVM version' "$NODE_FAIL_OUTPUT"

JAVA_FAIL_HOME="$TMP_DIR/java-fail-home"
JAVA_FAIL_BIN="$TMP_DIR/java-fail-bin"
mkdir -p "$JAVA_FAIL_HOME" "$JAVA_FAIL_BIN"
cat > "$JAVA_FAIL_BIN/curl" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$JAVA_FAIL_BIN/curl"
JAVA_FAIL_OUTPUT="$TMP_DIR/java-fail-output"
if HOME="$JAVA_FAIL_HOME" PATH="$JAVA_FAIL_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/java.sh" >"$JAVA_FAIL_OUTPUT" 2>&1; then
  printf 'java installer should fail when SDKMAN init is not created\n' >&2
  exit 1
fi
grep -q 'SDKMAN installer completed but' "$JAVA_FAIL_OUTPUT"

JAVA_SILENT_HOME="$TMP_DIR/java-silent-home"
JAVA_SILENT_BIN="$TMP_DIR/java-silent-bin"
mkdir -p "$JAVA_SILENT_HOME/.sdkman/bin" "$JAVA_SILENT_BIN"
cat > "$JAVA_SILENT_HOME/.sdkman/bin/sdkman-init.sh" <<'EOF'
sdk() {
  return 0
}
EOF
JAVA_SILENT_OUTPUT="$TMP_DIR/java-silent-output"
if HOME="$JAVA_SILENT_HOME" PATH="$JAVA_SILENT_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/java.sh" >"$JAVA_SILENT_OUTPUT" 2>&1; then
  printf 'java installer should fail when sdk install does not create a Java candidate\n' >&2
  exit 1
fi
grep -q 'Java 11 installation did not create an SDKMAN candidate' "$JAVA_SILENT_OUTPUT"

XML_HOME="$TMP_DIR/xml-home"
XML_BIN="$TMP_DIR/xml-bin"
XML_LOG="$TMP_DIR/xml.log"
XML_JAR_URL='https://repo.eclipse.org/content/repositories/lemminx-releases/org/eclipse/lemminx/org.eclipse.lemminx/0.31.1/org.eclipse.lemminx-0.31.1-uber.jar'
XML_EXPECTED_SHA1='1d65f934e0dc1bdde082b77ffda6d1081b90a0c3'
mkdir -p "$XML_HOME" "$XML_BIN"
cat > "$XML_BIN/java" <<'EOF'
#!/bin/bash
printf 'java %s\n' "$*" >> "$XML_LOG"
exit 0
EOF
cat > "$XML_BIN/curl" <<'EOF'
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
cat > "$XML_BIN/shasum" <<'EOF'
#!/bin/bash
if [ "$1" = "-a" ] && [ "$2" = "1" ]; then
  printf '%s  %s\n' "$XML_EXPECTED_SHA1" "$3"
  exit 0
fi
exit 1
EOF
chmod +x "$XML_BIN/java" "$XML_BIN/curl" "$XML_BIN/shasum"

HOME="$XML_HOME" PATH="$XML_BIN:/usr/bin:/bin" XML_LOG="$XML_LOG" XML_EXPECTED_SHA1="$XML_EXPECTED_SHA1" bash "$REPO_ROOT/setup/languages/xml.sh" >/dev/null
[ -s "$XML_HOME/.local/share/lemminx/org.eclipse.lemminx-0.31.1-uber.jar" ]
[ -x "$XML_HOME/.local/bin/lemminx" ]
grep -q "curl $XML_JAR_URL" "$XML_LOG"
grep -q "curl $XML_JAR_URL.sha1" "$XML_LOG"
HOME="$XML_HOME" PATH="$XML_BIN:/usr/bin:/bin" XML_LOG="$XML_LOG" "$XML_HOME/.local/bin/lemminx" --stdio
grep -q "java -jar $XML_HOME/.local/share/lemminx/org.eclipse.lemminx-0.31.1-uber.jar --stdio" "$XML_LOG"

DOCTOR_HOME="$TMP_DIR/doctor-home"
DOCTOR_BIN="$TMP_DIR/doctor-bin"
mkdir -p "$DOCTOR_HOME" "$DOCTOR_BIN"
cat > "$DOCTOR_BIN/git" <<'EOF'
#!/bin/bash
exit 0
EOF
cat > "$DOCTOR_BIN/bash" <<'EOF'
#!/bin/bash
exec /bin/bash "$@"
EOF
cat > "$DOCTOR_BIN/uname" <<'EOF'
#!/bin/bash
printf 'Darwin\n'
EOF
chmod +x "$DOCTOR_BIN/git" "$DOCTOR_BIN/bash" "$DOCTOR_BIN/uname"
DOCTOR_OUTPUT="$(HOME="$DOCTOR_HOME" PATH="$DOCTOR_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/doctor.sh")"
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'brew missing — run ./setup.sh bootstrap before brew-managed setup'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'mise missing — run ./setup.sh brew-packages before runtime setup'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'ruff missing; run ./setup.sh python'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'biome missing; run ./setup.sh typescript'
printf '%s' "$DOCTOR_OUTPUT" | grep -q 'Doctor completed'

CLEAN_HOME="$TMP_DIR/clean-home"
mkdir -p "$CLEAN_HOME/.config/zed"
cp "$REPO_ROOT/home/dot_zshrc" "$CLEAN_HOME/.zshrc"
cp "$REPO_ROOT/home/dot_config/zed/settings.json" "$CLEAN_HOME/.config/zed/settings.json"
printf 'old zshrc\n' > "$CLEAN_HOME/.zshrc.backup.20260101-010101"
printf 'old zed settings\n' > "$CLEAN_HOME/.config/zed/settings.json.backup.20260101-010101"
printf 'keep unrelated\n' > "$CLEAN_HOME/.config/zed/settings.json.backup.not-managed"
HOME="$CLEAN_HOME" SETUP_YES=1 SETUP_NO_INPUT=1 bash "$REPO_ROOT/setup/clean-backups.sh" >/dev/null
[ ! -e "$CLEAN_HOME/.zshrc.backup.20260101-010101" ]
[ ! -e "$CLEAN_HOME/.config/zed/settings.json.backup.20260101-010101" ]
[ -e "$CLEAN_HOME/.config/zed/settings.json.backup.not-managed" ]

bash "$REPO_ROOT/setup/languages/go.sh" >/dev/null
bash "$REPO_ROOT/setup/languages/bun.sh" >/dev/null

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

grep -q 'go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0' "$LOG_FILE"
grep -q 'go install mvdan.cc/gofumpt@latest' "$LOG_FILE"

if grep -q 'bun install -g' "$LOG_FILE"; then
  printf 'languages/bun.sh should not install Bun packages\n' >&2
  exit 1
fi

: > "$LOG_FILE"

PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/gno.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/typescript.sh" >/dev/null

grep -q 'go install github.com/gnolang/gno/gnovm/cmd/gno@latest' "$LOG_FILE"
grep -q 'go install github.com/gnoverse/gnopls@latest' "$LOG_FILE"
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

cat > "$FAKE_BIN/brew" <<EOF
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

chmod +x "$TMP_DIR/fake-go-prefix/bin/go" "$FAKE_HOME/.bun/bin/bun" "$FAKE_HOME/.bun/bin/bunx" "$FAKE_BIN/brew"

PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/go.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/gno.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/languages/typescript.sh" >/dev/null
PATH="$FAKE_BIN:/usr/bin:/bin" bash "$REPO_ROOT/setup/apps/opencode.sh" >/dev/null

grep -q 'go version' "$LOG_FILE"
grep -q 'go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0' "$LOG_FILE"
grep -q 'go install github.com/gnolang/gno/gnovm/cmd/gno@latest' "$LOG_FILE"
grep -q 'bun install -g typescript' "$LOG_FILE"
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

# shellcheck disable=SC2016
grep -q 'eval "$(brew shellenv)"' "$BOOTSTRAP_HOME/.zprofile"

[ ! -e "$REPO_ROOT/link.sh" ]
grep -q 'setup/link.sh' "$REPO_ROOT/setup/commands/40-links"
# shellcheck disable=SC2016
grep -q 'eval "$(brew shellenv)"' "$REPO_ROOT/setup/commands/10-bootstrap"
grep -q 'SETUP_SKIP_COMMANDS' "$REPO_ROOT/setup/commands/30-languages"
[ ! -e "$REPO_ROOT/setup/commands/35-tool-packages" ]
[ ! -e "$REPO_ROOT/setup/packages/go.sh" ]
[ ! -e "$REPO_ROOT/setup/packages/bun.sh" ]
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
grep -q 'mise install' "$REPO_ROOT/setup/commands/20-brew-packages"
grep -q 'mise install --dry-run-code' "$REPO_ROOT/setup/doctor.sh"
grep -q 'mise activate zsh' "$REPO_ROOT/home/dot_zshrc"
grep -q 'cask "brave-browser"' "$REPO_ROOT/Brewfile"
grep -q 'PLAYWRIGHT_MCP_EXECUTABLE_PATH' "$REPO_ROOT/home/dot_zshrc"
if grep -q 'kaku' "$REPO_ROOT/home/dot_zshrc"; then
  printf 'home/dot_zshrc should not reference kaku\n' >&2
  exit 1
fi
