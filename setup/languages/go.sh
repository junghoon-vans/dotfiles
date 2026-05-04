#!/bin/bash
# Description: Install Go via mise plus Go formatter/linter tools.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Go runtime and tooling..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Go. Run ./setup.sh brew-packages first."
    exit 1
fi

(
    cd "$DOTFILES_DIR" || exit
    mise install go
)
print_success "Go runtime installed via mise"

if command -v brew >/dev/null 2>&1; then
    if brew list gopls >/dev/null 2>&1; then
        print_success "gopls already installed"
    else
        brew install gopls
        print_success "gopls installed"
    fi
else
    print_info "Homebrew not found, skipping gopls installation"
fi

print_info "Installing github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0..."
(
    cd "$DOTFILES_DIR" || exit
    mise exec -- go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0
)
print_success "golangci-lint installed"

print_info "Installing mvdan.cc/gofumpt@latest..."
(
    cd "$DOTFILES_DIR" || exit
    mise exec -- go install mvdan.cc/gofumpt@latest
)
print_success "gofumpt installed"
