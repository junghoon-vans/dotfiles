#!/bin/bash
# Description: Install Go, gopls, and Go formatter/linter tools.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Go runtime..."

if ! command -v brew &> /dev/null; then
    print_error "Homebrew is required to install go@1.25"
    exit 1
fi

for formula in go@1.25 gopls; do
    if brew list "$formula" >/dev/null 2>&1; then
        print_success "$formula already installed"
    else
        brew install "$formula"
        print_success "$formula installed"
    fi
done

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

print_info "Installing github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0..."
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0
print_success "golangci-lint installed"

print_info "Installing mvdan.cc/gofumpt@latest..."
go install mvdan.cc/gofumpt@latest
print_success "gofumpt installed"
