#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Checking Go runtime..."

if command -v brew &> /dev/null; then
    go_prefix="$(brew --prefix go@1.25 2>/dev/null || true)"
    if [ -n "$go_prefix" ] && [ -d "$go_prefix/bin" ]; then
        export PATH="$go_prefix/bin:$PATH"
    fi
elif [ -d "/opt/homebrew/opt/go@1.25/bin" ]; then
    export PATH="/opt/homebrew/opt/go@1.25/bin:$PATH"
elif [ -d "/usr/local/opt/go@1.25/bin" ]; then
    export PATH="/usr/local/opt/go@1.25/bin:$PATH"
fi

if command -v go &> /dev/null; then
    print_success "Go already installed ($(go version))"
else
    print_info "Go not found. Install it through the brew-packages phase."
fi
