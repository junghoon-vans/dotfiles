#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Rust..."

if command -v rustc &> /dev/null; then
    print_success "Rust already installed ($(rustc --version))"
else
    print_info "Do you want to install Rust? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        print_success "Rust installed successfully"
    else
        print_info "Skipping Rust installation"
    fi
fi
