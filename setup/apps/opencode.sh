#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

print_step "Setting up OpenCode and oh-my-openagent..."

if ! command -v bun &> /dev/null; then
    print_error "Bun is required for OpenCode setup. Run ./setup.sh bun first."
    exit 1
fi

print_info "Installing opencode-ai..."
bun install -g opencode-ai
print_success "opencode-ai installed"

print_info "Installing oh-my-openagent..."
bun install -g oh-my-openagent
print_success "oh-my-openagent installed"

bunx oh-my-openagent install --no-tui --claude=no --openai=yes --gemini=no --copilot=no
print_success "oh-my-openagent configured"
