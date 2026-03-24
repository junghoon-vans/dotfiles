#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Creating symlinks for dotfiles..."

if [ -f "$SETUP_DIR/link.sh" ]; then
    chmod +x "$SETUP_DIR/link.sh"
    "$SETUP_DIR/link.sh"
    print_success "Symlinks created"
else
    print_error "setup/link.sh not found!"
    exit 1
fi
