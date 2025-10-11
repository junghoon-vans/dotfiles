#!/bin/bash

# Dotfiles Installation Script
# This script creates symlinks from the home directory to dotfiles in ~/workspace/dotfiles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Dotfiles directory (automatically detects script location)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of files to symlink
FILES=".zshrc .gitconfig .gitignore_global"

echo -e "${GREEN}Starting dotfiles installation...${NC}"
echo ""

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

# Create symlinks
for file in $FILES; do
    create_symlink "$file"
done

echo ""
echo -e "${GREEN}Dotfiles installation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Install recommended Oh My Zsh plugins:"
echo "   git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
echo "   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
echo "   git clone https://github.com/zsh-users/zsh-completions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions"
echo ""
echo "2. Install Spaceship theme:"
echo "   git clone https://github.com/spaceship-prompt/spaceship-prompt.git ~/.oh-my-zsh/custom/themes/spaceship-prompt --depth=1"
echo "   ln -s ~/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
echo ""
echo "3. Reload your shell configuration:"
echo "   source ~/.zshrc"
echo ""
