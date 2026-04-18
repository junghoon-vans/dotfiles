#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Checking Go runtime..."

if command -v brew &> /dev/null; then
    go_prefix="$(brew --prefix go@1.25 2>/dev/null || true)"
    if [ -n "$go_prefix" ] && [ -d "$go_prefix/bin" ]; then
        prepend_path_if_dir "$go_prefix/bin"
    fi
else
    homebrew_prefix="$(detect_homebrew_prefix)"
    if [ -n "$homebrew_prefix" ]; then
        prepend_path_if_dir "$homebrew_prefix/opt/go@1.25/bin"
    fi
fi

if command -v go &> /dev/null; then
    print_success "Go already installed ($(go version))"
else
    print_info "Go not found. Install it through the brew-packages command."
fi
