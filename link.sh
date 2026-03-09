#!/bin/bash

# Dotfiles Link Script
# This script creates symlinks from the home directory to dotfiles in this repository

set -euo pipefail

# Colors for output
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Dotfiles directory (automatically detects script location)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of files to symlink
FILES=".zshrc .gitconfig .gitignore_global"


# Function to create backup
backup_file() {
    local target="$1"
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -f "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d-%H%M%S)"
        echo -e "${YELLOW}Backing up $target → $backup${NC}"
        mv "$target" "$backup"
    fi
}

# Function to create symlink
create_symlink() {
    local file=$1
    local source="$DOTFILES_DIR/$file"
    local target="$HOME/$file"

    if [ ! -f "$source" ]; then
        echo -e "${RED}✗${NC} $file not found in $DOTFILES_DIR"
        return
    fi

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo -e "${GREEN}✓${NC} Already linked $file"
        return
    fi

    backup_file "$target"
    ln -sf "$source" "$target"
    echo -e "${GREEN}✓${NC} Linked $file"
}

# Function to create .config file symlink
create_config_symlink() {
    local config_file=$1
    local source="$DOTFILES_DIR/.config/$config_file"
    local target="$HOME/.config/$config_file"
    local target_dir
    target_dir=$(dirname "$target")

    if [ ! -f "$source" ]; then
        echo -e "${RED}✗${NC} .config/$config_file not found in $DOTFILES_DIR"
        return
    fi

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo -e "${GREEN}✓${NC} Already linked .config/$config_file"
        return
    fi

    mkdir -p "$target_dir"
    backup_file "$target"
    ln -sf "$source" "$target"
    echo -e "${GREEN}✓${NC} Linked .config/$config_file"
}

# Create symlinks
for file in $FILES; do
    create_symlink "$file"
done

# Create .config symlinks (auto-discover all files in .config/)
if [ -d "$DOTFILES_DIR/.config" ]; then
    while IFS= read -r -d '' config_file; do
        config_file="${config_file#"$DOTFILES_DIR/.config/"}"
        create_config_symlink "$config_file"
    done < <(find "$DOTFILES_DIR/.config" -type f -print0)
fi

brew link --force libpq

# Create symlink for go@1.25 -> go
if [ -d "/opt/homebrew/opt/go@1.25" ]; then
    if [ -L "/opt/homebrew/opt/go" ]; then
        echo -e "${YELLOW}Removing existing go symlink${NC}"
        rm "/opt/homebrew/opt/go"
    fi
    ln -sf "/opt/homebrew/opt/go@1.25" "/opt/homebrew/opt/go"
    echo -e "${GREEN}✓${NC} Linked go@1.25 -> go"
fi
