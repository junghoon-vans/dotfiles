#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Creating symlinks for dotfiles..."

if [ -f "$DOTFILES_DIR/link.sh" ]; then
    chmod +x "$DOTFILES_DIR/link.sh"
    "$DOTFILES_DIR/link.sh"
    print_success "Symlinks created"
else
    print_error "link.sh not found!"
    exit 1
fi
