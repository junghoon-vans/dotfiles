#!/bin/bash
# Description: Install Gno CLI and gnopls using Go.

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Gno tooling..."

if command -v brew &> /dev/null; then
    go_prefix="$(brew --prefix go@1.25 2>/dev/null || true)"
    if [ -n "$go_prefix" ] && [ -d "$go_prefix/bin" ]; then
        prepend_path_if_dir "$go_prefix/bin"
    fi
fi

if ! command -v go &> /dev/null; then
    print_error "Go is required for Gno tooling. Run ./setup.sh go first."
    exit 1
fi

print_info "Installing github.com/gnolang/gno/gnovm/cmd/gno@latest..."
go install github.com/gnolang/gno/gnovm/cmd/gno@latest
print_success "gno installed"

print_info "Installing github.com/gnoverse/gnopls@latest..."
go install github.com/gnoverse/gnopls@latest
print_success "gnopls installed"
