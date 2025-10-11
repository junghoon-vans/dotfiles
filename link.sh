#!/bin/bash

# Dotfiles Link Script
# This script creates symlinks from the home directory to dotfiles in this repository

set -e

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

# Neovim config files to symlink (relative to nvim directory)
NVIM_FILES="lua/config/lazy.lua lua/config/options.lua"


# Function to create backup
backup_file() {
    if [ -f "$1" ] || [ -L "$1" ]; then
        echo -e "${YELLOW}Backing up existing $1 to $1.backup${NC}"
        mv "$1" "$1.backup"
    fi
}

# Function to create symlink
create_symlink() {
    local file=$1
    local source="$DOTFILES_DIR/$file"
    local target="$HOME/$file"

    if [ -f "$source" ]; then
        backup_file "$target"
        ln -sf "$source" "$target"
        echo -e "${GREEN}✓${NC} Linked $file"
    else
        echo -e "${RED}✗${NC} $file not found in $DOTFILES_DIR"
    fi
}

# Function to create neovim config symlink
create_nvim_symlink() {
    local nvim_file=$1
    local source="$DOTFILES_DIR/nvim/$nvim_file"
    local target="$HOME/.config/nvim/$nvim_file"
    local target_dir=$(dirname "$target")

    if [ -f "$source" ]; then
        # Create directory structure if it doesn't exist
        mkdir -p "$target_dir"

        # Backup existing file
        if [ -f "$target" ] || [ -L "$target" ]; then
            echo -e "${YELLOW}Backing up existing $target to $target.backup${NC}"
            mv "$target" "$target.backup"
        fi

        ln -sf "$source" "$target"
        echo -e "${GREEN}✓${NC} Linked nvim/$nvim_file"
    else
        echo -e "${RED}✗${NC} nvim/$nvim_file not found in $DOTFILES_DIR"
    fi
}

# Create symlinks
for file in $FILES; do
    create_symlink "$file"
done

# Create neovim config symlinks
for nvim_file in $NVIM_FILES; do
    create_nvim_symlink "$nvim_file"
done
