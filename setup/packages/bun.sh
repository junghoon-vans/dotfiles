#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Bun global packages..."

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if ! command -v bun &> /dev/null; then
    print_info "Bun not found, skipping Bun package installation"
    exit 0
fi

print_info "Installing opencode-ai..."
bun install -g opencode-ai
print_success "opencode-ai installed"

print_info "Installing oh-my-opencode..."
bun install -g oh-my-opencode
print_success "oh-my-opencode installed"

print_info "Installing typescript..."
bun install -g typescript
print_success "typescript installed"

print_info "Installing typescript-language-server..."
bun install -g typescript-language-server
print_success "typescript-language-server installed"
