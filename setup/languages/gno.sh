#!/bin/bash
# Description: Install Gno CLI and gnopls using Go.

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Gno tooling..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required for Gno tooling. Run ./setup.sh brew-packages first."
    exit 1
fi

print_info "Installing github.com/gnolang/gno/gnovm/cmd/gno@latest..."
(
    cd "$DOTFILES_DIR" || exit
    mise install go
    mise exec -- go install github.com/gnolang/gno/gnovm/cmd/gno@latest
)
print_success "gno installed"

print_info "Installing github.com/gnoverse/gnopls@latest..."
(
    cd "$DOTFILES_DIR" || exit
    mise exec -- go install github.com/gnoverse/gnopls@latest
)
print_success "gnopls installed"
