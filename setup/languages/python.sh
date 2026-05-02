#!/bin/bash
# Description: Install uv, Python, pyright, and ruff.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Python (latest stable) via uv..."

if ! command -v brew &> /dev/null; then
    print_error "Homebrew is required to install uv"
    exit 1
fi

for formula in uv pyright ruff; do
    if brew list "$formula" >/dev/null 2>&1; then
        print_success "$formula already installed"
    else
        brew install "$formula"
        print_success "$formula installed"
    fi
done

export PATH="$HOME/.local/bin:$PATH"

print_info "Installing latest stable Python with default python/python3 executables..."
uv python install --preview-features python-install-default --default

if command -v python3 &> /dev/null; then
    print_success "Python ready ($(python3 --version 2>&1))"
else
    print_error "python3 command not found after uv install"
    exit 1
fi
