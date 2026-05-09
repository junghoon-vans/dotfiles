#!/bin/bash
# Description: Install Node.js and Corepack pnpm via mise.

# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Node.js runtime and pnpm..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Node.js. Run ./setup.sh brew-packages first."
    exit 1
fi

(
    cd "$DOTFILES_DIR" || exit
    mise install node
    mise exec -- node --version
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 mise exec -- corepack enable pnpm
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 mise exec -- corepack install --global pnpm@latest-10
    mise exec -- pnpm --version
)
print_success "Node.js runtime and pnpm installed via mise"
