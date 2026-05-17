#!/bin/bash
# Description: Install Bun via mise.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Bun..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Bun. Run ./setup.sh brew-packages first."
    exit 1
fi

sync_mise_global_config

(
    cd "$DOTFILES_DIR" || exit
    mise install bun
    mise exec -- bun --version
)
print_success "Bun runtime installed via mise"
