#!/bin/bash
# Description: Run repository validation and setup smoke checks.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SETUP_DIR/.." && pwd)"
export DOTFILES_DIR SETUP_DIR

# shellcheck source=setup/lib/common.sh
source "$SETUP_DIR/lib/common.sh"

print_step "Running repository checks..."

print_info "Checking shell syntax..."
bash -n \
    "$DOTFILES_DIR/setup.sh" \
    "$SETUP_DIR/main.sh" \
    "$SETUP_DIR/lib/common.sh" \
    "$SETUP_DIR"/commands/* \
    "$SETUP_DIR"/languages/*.sh \
    "$SETUP_DIR"/apps/*.sh \
    "$SETUP_DIR/check.sh" \
    "$SETUP_DIR/doctor.sh" \
    "$DOTFILES_DIR"/tests/setup/*.sh

if command -v shellcheck >/dev/null 2>&1; then
    print_info "Running shellcheck..."
    shellcheck -x -S warning \
        "$DOTFILES_DIR/setup.sh" \
        "$SETUP_DIR/main.sh" \
        "$SETUP_DIR/lib/common.sh" \
        "$SETUP_DIR"/commands/* \
        "$SETUP_DIR"/languages/*.sh \
        "$SETUP_DIR"/apps/*.sh \
        "$SETUP_DIR/check.sh" \
        "$SETUP_DIR/doctor.sh" \
        "$DOTFILES_DIR"/tests/setup/*.sh
else
    print_info "shellcheck not found; skipping shellcheck"
fi

if command -v actionlint >/dev/null 2>&1; then
    print_info "Running actionlint..."
    actionlint
else
    print_info "actionlint not found; skipping actionlint"
fi

print_info "Validating JSON config..."
python3 -m json.tool "$DOTFILES_DIR/home/dot_config/opencode/opencode.json" >/dev/null
python3 -m json.tool "$DOTFILES_DIR/home/dot_config/opencode/oh-my-openagent.json" >/dev/null
python3 -m json.tool "$DOTFILES_DIR/home/dot_config/opencode/tui.json" >/dev/null
python3 -m json.tool "$DOTFILES_DIR/home/dot_config/karabiner/karabiner.json" >/dev/null

print_info "Validating JSONC config..."
python3 - "$DOTFILES_DIR/home/dot_config/zed/settings.json" <<'PY'
import json
import re
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as file:
    lines = [line for line in file if not line.lstrip().startswith("//")]

content = "".join(lines)
content = re.sub(r",(\s*[}\]])", r"\1", content)
json.loads(content)
PY

print_info "Checking Brewfile syntax..."
ruby -c "$DOTFILES_DIR/Brewfile" >/dev/null

print_info "Validating mise config..."
python3 - "$DOTFILES_DIR/mise.toml" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])

try:
    import tomllib
except ModuleNotFoundError:
    content = path.read_text(encoding="utf-8")
    required_entries = [
        "[tools]",
        'go = "1.25"',
        'node = "24"',
        'python = "3.13"',
        'rust = "latest"',
        'java = "temurin-21"',
        'bun = "latest"',
    ]
    missing = [entry for entry in required_entries if entry not in content]
    if missing:
        raise SystemExit(f"mise.toml missing entries: {', '.join(missing)}")
else:
    with path.open("rb") as file:
        config = tomllib.load(file)
    tools = config.get("tools")
    if not isinstance(tools, dict):
        raise SystemExit("mise.toml must define a [tools] table")
    expected_tools = {
        "go": "1.25",
        "node": "24",
        "python": "3.13",
        "rust": "latest",
        "java": "temurin-21",
        "bun": "latest",
    }
    if tools != expected_tools:
        raise SystemExit(f"mise.toml tools mismatch: {tools!r}")
PY

print_info "Validating chezmoi source..."
if [ "$(tr -d '[:space:]' < "$DOTFILES_DIR/.chezmoiroot")" != "home" ]; then
    print_error ".chezmoiroot must point to home"
    exit 1
fi
if command -v chezmoi >/dev/null 2>&1; then
    chezmoi --source "$DOTFILES_DIR" --no-tty apply --dry-run --verbose >/dev/null
else
    print_info "chezmoi not found; skipping chezmoi dry-run"
fi

if command -v git >/dev/null 2>&1 && git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print_info "Checking git diff whitespace..."
    git -C "$DOTFILES_DIR" diff --check
fi

print_info "Running setup regression test..."
bash "$DOTFILES_DIR/tests/setup/setup-command-regression.sh"

print_success "Repository checks passed"
