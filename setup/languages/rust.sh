#!/bin/bash
# Description: Install Rust via mise plus Rust language server and test tooling.

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Rust runtime and tooling..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Rust. Run ./setup.sh brew-packages first."
    exit 1
fi

(
    cd "$DOTFILES_DIR" || exit
    mise install rust
    mise exec -- rustc --version
)
print_success "Rust runtime installed via mise"

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
