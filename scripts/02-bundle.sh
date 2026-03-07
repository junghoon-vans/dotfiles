#!/bin/bash
# shellcheck source=00-core.sh
source "$SCRIPTS_DIR/00-core.sh"

print_step "Installing Homebrew packages..."

if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    cd "$DOTFILES_DIR"
    brew bundle install
    print_success "Homebrew packages installed"
else
    print_error "Brewfile not found!"
    exit 1
fi
