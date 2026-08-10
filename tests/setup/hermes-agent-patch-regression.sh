#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$REPO_ROOT/home/run_after_hermes-agent-patch.sh"
ORIGINAL="$REPO_ROOT/docs/hermes-agent/2026.8.3/daemon_pool.py.original.py"
PATCHED="$REPO_ROOT/docs/hermes-agent/2026.8.3/daemon_pool.py.patched.py"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

FAKE_BIN="$TMP_DIR/bin"
FAKE_BREW_LOG="$TMP_DIR/brew.log"
mkdir -p "$FAKE_BIN"

cat >"$FAKE_BIN/brew" <<'EOF'
#!/bin/bash

set -euo pipefail

printf 'brew %s\n' "$*" >>"$FAKE_BREW_LOG"

case "${1:-}" in
    list)
        case "${2:-}" in
            --versions)
                [ "${3:-}" = "hermes-agent" ] || exit 1
                [ "${FAKE_BREW_INSTALLED:-1}" = "1" ] || exit 1
                printf 'hermes-agent %s\n' "$FAKE_BREW_VERSION"
                ;;
            --pinned)
                if [ -f "$FAKE_BREW_PINNED" ]; then
                    cat "$FAKE_BREW_PINNED"
                fi
                ;;
            *)
                exit 99
                ;;
        esac
        ;;
    --prefix)
        [ "${2:-}" = "hermes-agent" ] || exit 99
        printf '%s\n' "$FAKE_BREW_PREFIX"
        ;;
    pin)
        [ "${2:-}" = "hermes-agent" ] || exit 99
        printf 'hermes-agent\n' >"$FAKE_BREW_PINNED"
        ;;
    install|upgrade|bundle|services|unpin)
        exit 98
        ;;
    *)
        exit 99
        ;;
esac
EOF
chmod +x "$FAKE_BIN/brew"

prepare_fixture() {
    local name="$1"

    FIXTURE_ROOT="$TMP_DIR/$name"
    FIXTURE_HOME="$FIXTURE_ROOT/home"
    FIXTURE_PREFIX="$FIXTURE_ROOT/homebrew/hermes-agent"
    FIXTURE_TARGET="$FIXTURE_PREFIX/libexec/lib/python3.14/site-packages/tools/daemon_pool.py"
    FIXTURE_BACKUP="$FIXTURE_HOME/.hermes/patches/daemon_pool.py.2026.8.3.original.py"
    FIXTURE_PINNED="$FIXTURE_ROOT/pinned"
    mkdir -p "$(dirname "$FIXTURE_TARGET")" "$FIXTURE_HOME"
}

run_hook() {
    env \
        HOME="$FIXTURE_HOME" \
        PATH="$FAKE_BIN:/usr/bin:/bin" \
        CHEZMOI_SOURCE_DIR="$REPO_ROOT/home" \
        FAKE_BREW_LOG="$FAKE_BREW_LOG" \
        FAKE_BREW_PREFIX="$FIXTURE_PREFIX" \
        FAKE_BREW_PINNED="$FIXTURE_PINNED" \
        FAKE_BREW_VERSION="${1:-2026.8.3}" \
        FAKE_BREW_INSTALLED="${2:-1}" \
        bash "$HOOK"
}

file_identity() {
    if [ "$(uname -s)" = "Darwin" ]; then
        stat -f '%i' "$1"
    else
        stat -c '%i' "$1"
    fi
}

prepare_fixture original
cp "$ORIGINAL" "$FIXTURE_TARGET"
: >"$FAKE_BREW_LOG"
run_hook
cmp -s "$PATCHED" "$FIXTURE_TARGET"
cmp -s "$ORIGINAL" "$FIXTURE_BACKUP"
grep -Fxq 'brew pin hermes-agent' "$FAKE_BREW_LOG"

target_identity="$(file_identity "$FIXTURE_TARGET")"
run_hook
[ "$target_identity" = "$(file_identity "$FIXTURE_TARGET")" ]
[ "$(grep -c '^brew pin hermes-agent$' "$FAKE_BREW_LOG")" -eq 1 ]

prepare_fixture wrong-version
cp "$ORIGINAL" "$FIXTURE_TARGET"
: >"$FAKE_BREW_LOG"
if run_hook 2026.8.2; then
    printf 'wrong version should fail\n' >&2
    exit 1
fi
cmp -s "$ORIGINAL" "$FIXTURE_TARGET"
[ ! -e "$FIXTURE_BACKUP" ]
if grep -Fxq 'brew pin hermes-agent' "$FAKE_BREW_LOG"; then
    printf 'wrong version should not pin\n' >&2
    exit 1
fi

prepare_fixture unknown-target
printf 'unknown target\n' >"$FIXTURE_TARGET"
: >"$FAKE_BREW_LOG"
if run_hook; then
    printf 'unknown target should fail\n' >&2
    exit 1
fi
grep -Fxq 'unknown target' "$FIXTURE_TARGET"
[ ! -e "$FIXTURE_BACKUP" ]
if grep -Fxq 'brew pin hermes-agent' "$FAKE_BREW_LOG"; then
    printf 'unknown target should not pin\n' >&2
    exit 1
fi

prepare_fixture patched-without-backup
cp "$PATCHED" "$FIXTURE_TARGET"
: >"$FAKE_BREW_LOG"
if run_hook; then
    printf 'patched target without backup should fail\n' >&2
    exit 1
fi
cmp -s "$PATCHED" "$FIXTURE_TARGET"
[ ! -e "$FIXTURE_BACKUP" ]
if grep -Fxq 'brew pin hermes-agent' "$FAKE_BREW_LOG"; then
    printf 'patched target without backup should not pin\n' >&2
    exit 1
fi

prepare_fixture absent
cp "$ORIGINAL" "$FIXTURE_TARGET"
: >"$FAKE_BREW_LOG"
run_hook 2026.8.3 0
cmp -s "$ORIGINAL" "$FIXTURE_TARGET"
[ ! -e "$FIXTURE_BACKUP" ]
if grep -Eq '^brew (install|upgrade|bundle|services|unpin)' "$FAKE_BREW_LOG"; then
    printf 'hook invoked a prohibited Homebrew command\n' >&2
    exit 1
fi
if grep -Eq 'brew (install|upgrade|bundle|services|unpin)|launchctl|gateway' "$HOOK"; then
    printf 'hook contains a prohibited command\n' >&2
    exit 1
fi

printf 'hermes-agent patch regression passed\n'
