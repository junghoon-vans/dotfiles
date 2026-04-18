#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Go tool packages..."

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

if ! command -v go &> /dev/null; then
    print_info "Go not found, skipping Go tool installation"
    exit 0
fi

print_info "Installing github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0..."
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0
print_success "golangci-lint installed"

print_info "Installing mvdan.cc/gofumpt@latest..."
go install mvdan.cc/gofumpt@latest
print_success "gofumpt installed"

print_info "Installing github.com/gnolang/gno/gnovm/cmd/gno@latest..."
go install github.com/gnolang/gno/gnovm/cmd/gno@latest
print_success "gno installed"

print_info "Installing github.com/gnoverse/gnopls@latest..."
go install github.com/gnoverse/gnopls@latest
print_success "gnopls installed"
