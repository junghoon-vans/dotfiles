#!/bin/bash

set -euo pipefail

readonly HERMES_VERSION="2026.8.3"
readonly ORIGINAL_SHA256="148a18c801a28f4fb5a96eb20399052245599413a349d7df2fd0b4643ae910dc"
readonly PATCHED_SHA256="b48912a01f0696db165fc1bcb68e6bf055b1f32a67dd601c8bb857aca8b20f42"

die() {
    printf 'hermes-agent patch: %s\n' "$*" >&2
    exit 1
}

sha256_file() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    else
        die "sha256 utility not found"
    fi
}

require_hash() {
    local path="$1"
    local expected="$2"
    local label="$3"
    local actual

    [ -f "$path" ] || die "missing $label: $path"
    actual="$(sha256_file "$path")" || die "cannot hash $label: $path"
    [ "$actual" = "$expected" ] || die "$label checksum mismatch: $path"
}

if ! command -v brew >/dev/null 2>&1; then
    exit 0
fi

installed_versions=""
if ! installed_versions="$(brew list --versions hermes-agent 2>/dev/null)"; then
    [ -z "$installed_versions" ] && exit 0
    die "cannot inspect installed hermes-agent version"
fi
[ -n "$installed_versions" ] || exit 0

read -r installed_formula installed_version extra_version <<<"$installed_versions"
if [ "$installed_formula" != "hermes-agent" ] || [ "$installed_version" != "$HERMES_VERSION" ] || [ -n "${extra_version:-}" ]; then
    die "requires exactly hermes-agent $HERMES_VERSION; found: $installed_versions"
fi

[ -n "${CHEZMOI_SOURCE_FILE:-}" ] || die "CHEZMOI_SOURCE_FILE is required"
source_directory="$(cd "$(dirname "$CHEZMOI_SOURCE_FILE")" && pwd)"
repository_root="$(cd "$source_directory/.." && pwd)"
reference_directory="$repository_root/docs/hermes-agent/$HERMES_VERSION"
original_reference="$reference_directory/daemon_pool.py.original.py"
patched_reference="$reference_directory/daemon_pool.py.patched.py"

require_hash "$original_reference" "$ORIGINAL_SHA256" "original reference"
require_hash "$patched_reference" "$PATCHED_SHA256" "patched reference"

formula_prefix="$(brew --prefix hermes-agent)" || die "cannot resolve hermes-agent prefix"
target="$formula_prefix/libexec/lib/python3.14/site-packages/tools/daemon_pool.py"
target_directory="$(dirname "$target")"
[ -f "$target" ] || die "missing target: $target"
target_hash="$(sha256_file "$target")" || die "cannot hash target: $target"

: "${HOME:?HOME is required}"
backup_directory="$HOME/.hermes/patches"
backup="$backup_directory/daemon_pool.py.$HERMES_VERSION.original.py"

ensure_backup() {
    if [ -e "$backup" ]; then
        require_hash "$backup" "$ORIGINAL_SHA256" "original backup"
        return
    fi

    mkdir -p "$backup_directory"
    if ! (set -C; cat "$original_reference" >"$backup") 2>/dev/null; then
        [ -e "$backup" ] || die "cannot create original backup: $backup"
    fi
    require_hash "$backup" "$ORIGINAL_SHA256" "original backup"
}

require_backup() {
    [ -e "$backup" ] || die "missing original backup for already patched target: $backup"
    require_hash "$backup" "$ORIGINAL_SHA256" "original backup"
}

patch_tmp=""
cleanup() {
    [ -z "$patch_tmp" ] || rm -f "$patch_tmp"
}
trap cleanup EXIT

case "$target_hash" in
    "$ORIGINAL_SHA256")
        ensure_backup
        patch_tmp="$(mktemp "$target_directory/.daemon_pool.py.XXXXXX")" || die "cannot create patch temporary file"
        cp "$patched_reference" "$patch_tmp"
        mv -f "$patch_tmp" "$target"
        patch_tmp=""
        require_hash "$target" "$PATCHED_SHA256" "patched target"
        ;;
    "$PATCHED_SHA256")
        require_backup
        ;;
    *)
        die "refusing to modify unknown target content: $target"
        ;;
esac

pinned="$(brew list --pinned)" || die "cannot inspect pinned formulae"
if ! grep -Fxq "hermes-agent" <<<"$pinned"; then
    brew pin hermes-agent
fi
