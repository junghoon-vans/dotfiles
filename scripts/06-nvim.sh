#!/bin/bash
# shellcheck source=00-core.sh
source "$SCRIPTS_DIR/00-core.sh"

print_step "Installing LazyVim..."

if [ -d "$HOME/.config/nvim" ]; then
    print_info "Neovim config already exists, skipping LazyVim installation"
    print_info "(If you want to reinstall, backup and remove ~/.config/nvim first)"
else
    print_info "Installing LazyVim starter..."
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
    print_success "LazyVim installed"
fi
