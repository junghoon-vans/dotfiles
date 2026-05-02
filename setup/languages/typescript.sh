#!/bin/bash
# Description: Install TypeScript, TypeScript LSP, and Biome.

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing TypeScript tooling..."

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if ! command -v bun &> /dev/null; then
    print_error "Bun is required for TypeScript tooling. Run ./setup.sh bun first."
    exit 1
fi

print_info "Installing typescript..."
bun install -g typescript
print_success "typescript installed"

print_info "Installing typescript-language-server..."
bun install -g typescript-language-server
print_success "typescript-language-server installed"

if command -v brew >/dev/null 2>&1; then
    if brew list biome >/dev/null 2>&1; then
        print_success "biome already installed"
    else
        brew install biome
        print_success "biome installed"
    fi
else
    print_info "Homebrew not found, skipping Biome installation"
fi
