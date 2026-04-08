#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if command -v bunx &> /dev/null; then
    print_step "Setting up oh-my-openagent..."
    bunx oh-my-openagent install --no-tui --claude=no --openai=yes --gemini=no --copilot=no
    print_success "oh-my-openagent configured"
else
    print_info "bunx is not available yet, skipping oh-my-openagent bootstrap"
fi
