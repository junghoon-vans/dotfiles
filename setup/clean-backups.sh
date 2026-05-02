#!/bin/bash
# Description: Remove managed dotfile backup files created by the link command.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SETUP_DIR/.." && pwd)"
export DOTFILES_DIR SETUP_DIR

# shellcheck source=setup/lib/common.sh
source "$SETUP_DIR/lib/common.sh"

ROOT_FILES=".zshrc .gitconfig .gitignore_global"
BACKUP_SUFFIX_PATTERN='\.backup\.[0-9]{8}-[0-9]{6}$'

backup_candidates_file="$(mktemp)"
trap 'rm -f "$backup_candidates_file"' EXIT

collect_backups_for_target() {
    local source="$1"
    local target="$2"
    local backup=""

    if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$source" ]; then
        return 0
    fi

    for backup in "$target".backup.*; do
        [ -f "$backup" ] || continue
        if printf '%s\n' "$backup" | grep -Eq "$BACKUP_SUFFIX_PATTERN"; then
            printf '%s\n' "$backup" >> "$backup_candidates_file"
        fi
    done
}

print_step "Finding managed dotfile backups..."

for file in $ROOT_FILES; do
    collect_backups_for_target "$DOTFILES_DIR/$file" "$HOME/$file"
done

if [ -d "$DOTFILES_DIR/.config" ]; then
    while IFS= read -r -d '' source; do
        relative_path="${source#"$DOTFILES_DIR/"}"
        if [ "$relative_path" = ".config/AGENTS.md" ]; then
            continue
        fi
        collect_backups_for_target "$source" "$HOME/$relative_path"
    done < <(find "$DOTFILES_DIR/.config" -type f -print0)
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
