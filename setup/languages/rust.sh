#!/bin/bash
# Description: Install Rust, rust-analyzer, and Rust test tooling.

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Rust..."

if command -v brew >/dev/null 2>&1; then
    for formula in rust-analyzer cargo-nextest; do
        if brew list "$formula" >/dev/null 2>&1; then
            print_success "$formula already installed"
        else
            brew install "$formula"
            print_success "$formula installed"
        fi
    done
else
    print_info "Homebrew not found, skipping Rust language server and test tooling"
fi

if command -v rustc &> /dev/null; then
    print_success "Rust already installed ($(rustc --version))"
else
    print_info "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
    print_success "Rust installed successfully"
fi
