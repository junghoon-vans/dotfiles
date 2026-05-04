#!/bin/bash
# Description: Remove managed dotfile backup files created before chezmoi apply.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SETUP_DIR/.." && pwd)"
export DOTFILES_DIR SETUP_DIR

# shellcheck source=setup/lib/common.sh
source "$SETUP_DIR/lib/common.sh"

CHEZMOI_SOURCE="$DOTFILES_DIR/home"
BACKUP_SUFFIX_PATTERN='\.backup\.[0-9]{8}-[0-9]{6}$'

backup_candidates_file="$(mktemp)"
trap 'rm -f "$backup_candidates_file"' EXIT

collect_backups_for_target() {
    local source="$1"
    local target="$2"
    local backup=""

    if [ -L "$target" ]; then
        [ "$(readlink "$target")" = "$source" ] || return 0
    elif [ -f "$target" ]; then
        diff -q "$source" "$target" >/dev/null 2>&1 || return 0
    else
        return 0
    fi

    for backup in "$target".backup.*; do
        [ -f "$backup" ] || continue
        if printf '%s\n' "$backup" | grep -Eq "$BACKUP_SUFFIX_PATTERN"; then
            printf '%s\n' "$backup" >> "$backup_candidates_file"
        fi
    done
}

target_for_source() {
    local source="$1"
    local relative_path="${source#"$CHEZMOI_SOURCE/"}"

    case "$relative_path" in
        dot_config/*)
            printf '%s\n' "$HOME/.config/${relative_path#dot_config/}"
            ;;
        dot_*)
            printf '%s\n' "$HOME/.${relative_path#dot_}"
            ;;
        *)
            return 1
            ;;
    esac
}

print_step "Finding managed dotfile backups..."

if [ -d "$CHEZMOI_SOURCE" ]; then
    while IFS= read -r -d '' source; do
        target="$(target_for_source "$source")" || continue
        collect_backups_for_target "$source" "$target"
    done < <(find "$CHEZMOI_SOURCE" -type f -print0)
fi

if [ ! -s "$backup_candidates_file" ]; then
    print_success "No managed dotfile backups found"
    exit 0
fi

print_info "Backups to remove:"
while IFS= read -r backup; do
    printf '  %s\n' "$backup"
done < "$backup_candidates_file"

backup_count="$(wc -l < "$backup_candidates_file" | tr -d '[:space:]')"
if ! confirm "Remove $backup_count managed backup file(s)?" "no"; then
    print_info "Backup cleanup cancelled"
    exit 0
fi

while IFS= read -r backup; do
    rm -f "$backup"
done < "$backup_candidates_file"

print_success "Removed $backup_count managed backup file(s)"
