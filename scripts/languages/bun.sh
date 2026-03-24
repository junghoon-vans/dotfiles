#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Bun..."

if command -v bun &> /dev/null; then
    print_success "Bun already installed ($(bun --version))"
else
    print_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    print_success "Bun installed"
fi

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if [ -f "$DOTFILES_DIR/Bunfile" ]; then
    print_step "Installing global bun packages from Bunfile..."
    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ "$package" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${package// }" ]] && continue
        print_info "Installing $package..."
        bun install -g "$package"
        print_success "$package installed"
    done < "$DOTFILES_DIR/Bunfile"
fi
