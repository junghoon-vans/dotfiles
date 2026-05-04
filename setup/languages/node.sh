#!/bin/bash
# Description: Install Node.js via mise.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Node.js runtime..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Node.js. Run ./setup.sh brew-packages first."
    exit 1
fi

(
    cd "$DOTFILES_DIR" || exit
    mise install node
    mise exec -- node --version
)
print_success "Node.js runtime installed via mise"
