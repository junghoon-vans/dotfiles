#!/bin/bash

# Dotfiles Apply Script
# This script prepares backups for existing files, then applies dotfiles with chezmoi.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SETUP_DIR/.." && pwd)"

source "$SETUP_DIR/lib/common.sh"

CHEZMOI_SOURCE="$DOTFILES_DIR/home"


# Function to create backup
backup_file() {
    local source="$1"
    local target="$2"
    local backup=""

    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        return 0
    fi

    backup="${target}.backup.$(date +%Y%m%d-%H%M%S)"

    if [ -L "$target" ]; then
        if [ "$(readlink "$target")" = "$source" ]; then
            rm "$target"
        else
            echo -e "${YELLOW}Backing up $target → $backup${NC}"
            mv "$target" "$backup"
        fi
    elif [ -f "$target" ]; then
        if diff -q "$source" "$target" > /dev/null 2>&1; then
            rm "$target"  # identical content, silently re-link
        else
            echo -e "${YELLOW}Backing up $target → $backup${NC}"
            mv "$target" "$backup"
        fi
    else
        echo -e "${YELLOW}Backing up $target → $backup${NC}"
        mv "$target" "$backup"
    fi
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

if ! command -v chezmoi >/dev/null 2>&1; then
    print_error "chezmoi not found; run ./setup.sh brew-packages first"
    exit 1
fi

if [ ! -d "$CHEZMOI_SOURCE" ]; then
    print_error "chezmoi source not found: $CHEZMOI_SOURCE"
    exit 1
fi

while IFS= read -r -d '' source; do
    target="$(target_for_source "$source")" || continue
    target_dir="$(dirname "$target")"
    mkdir -p "$target_dir"
    backup_file "$source" "$target"
done < <(find "$CHEZMOI_SOURCE" -type f -print0)

print_info "Applying dotfiles with chezmoi..."
chezmoi --source "$DOTFILES_DIR" --force --no-tty apply
print_success "Dotfiles applied with chezmoi"
