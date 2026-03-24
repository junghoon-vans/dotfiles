#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Python (latest stable) via uv..."

if ! command -v uv &> /dev/null; then
    print_info "uv is not installed. Run ./setup.sh brew-packages or brew install uv"
    exit 0
fi

export PATH="$HOME/.local/bin:$PATH"

print_info "Installing latest stable Python with default python/python3 executables..."
uv python install --preview-features python-install-default --default

if command -v python3 &> /dev/null; then
    print_success "Python ready ($(python3 --version 2>&1))"
else
    print_error "python3 command not found after uv install"
    exit 1
fi
