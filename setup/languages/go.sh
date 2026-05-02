#!/bin/bash
# Description: Install go@1.25 with Homebrew and activate it on PATH.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Go runtime..."

if ! command -v brew &> /dev/null; then
    print_error "Homebrew is required to install go@1.25"
    exit 1
fi

if brew list go@1.25 >/dev/null 2>&1; then
    print_success "go@1.25 already installed"
else
    brew install go@1.25
    print_success "go@1.25 installed"
fi

go_prefix="$(brew --prefix go@1.25 2>/dev/null || true)"
if [ -n "$go_prefix" ] && [ -d "$go_prefix/bin" ]; then
    prepend_path_if_dir "$go_prefix/bin"
fi

if command -v go &> /dev/null; then
    print_success "Go ready ($(go version))"
else
    print_error "go command not found after go@1.25 install"
    exit 1
fi
