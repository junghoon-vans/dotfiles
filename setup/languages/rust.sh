#!/bin/bash

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Rust..."

if command -v rustc &> /dev/null; then
    print_success "Rust already installed ($(rustc --version))"
else
    if confirm "Install Rust with rustup?" "no"; then
        print_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
        print_success "Rust installed successfully"
    else
        print_info "Skipping Rust installation"
    fi
fi
