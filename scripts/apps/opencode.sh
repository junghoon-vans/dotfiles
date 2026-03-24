#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if command -v bunx &> /dev/null; then
    print_step "Setting up oh-my-opencode..."
    bunx oh-my-opencode install --no-tui --claude=no --openai=yes --gemini=no --copilot=no
    print_success "oh-my-opencode configured"
else
    print_info "bunx is not available yet, skipping oh-my-opencode bootstrap"
fi
