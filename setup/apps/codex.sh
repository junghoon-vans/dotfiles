#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Setting up Codex CLI and LazyCodex..."

if ! command -v mise &> /dev/null; then
    print_error "mise is required for Codex setup. Run ./setup.sh brew-packages first."
    exit 1
fi

if ! (cd "$DOTFILES_DIR" && mise exec -- node --version &> /dev/null 2>&1); then
    print_error "Node.js is required for Codex setup. Run ./setup.sh node first."
    exit 1
fi

print_info "Installing @openai/codex..."
(cd "$DOTFILES_DIR" && mise exec -- npm install -g @openai/codex)
print_success "@openai/codex installed"

print_info "Bootstrapping LazyCodex..."
(cd "$DOTFILES_DIR" && mise exec -- npx --yes lazycodex-ai install --no-tui --codex-autonomous)
print_success "LazyCodex configured"
