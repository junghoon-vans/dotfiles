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

    rust_analyzer_path=""
    rust_analyzer_prefix="$(brew --prefix rust-analyzer 2>/dev/null || true)"
    if [ -n "$rust_analyzer_prefix" ] && [ -x "$rust_analyzer_prefix/bin/rust-analyzer" ]; then
        rust_analyzer_path="$rust_analyzer_prefix/bin/rust-analyzer"
    else
        rust_analyzer_candidate="$(command -v rust-analyzer 2>/dev/null || true)"
        if [ -n "$rust_analyzer_candidate" ] && [ "$rust_analyzer_candidate" != "$HOME/.local/bin/rust-analyzer" ]; then
            rust_analyzer_path="$rust_analyzer_candidate"
        fi
    fi

    if [ -z "$rust_analyzer_path" ]; then
        print_error "rust-analyzer executable not found after Homebrew installation"
        exit 1
    fi

    create_mise_tool_path_wrapper "rust-analyzer" "$rust_analyzer_path"
    print_success "rust-analyzer wrapper created in $HOME/.local/bin"
else
    print_info "Homebrew not found, skipping Rust language server and test tooling"
fi
