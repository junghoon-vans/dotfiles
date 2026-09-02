#!/bin/bash

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

print_step "Installing Oh My Pi..."

if ! command -v bun >/dev/null 2>&1; then
    print_error "Bun is required for Oh My Pi setup. Run ./setup.sh bun first."
    exit 1
fi

run_with_bun() {
    if command -v mise >/dev/null 2>&1; then
        (cd "$DOTFILES_DIR" && mise exec -- "$@")
    else
        "$@"
    fi
}

print_info "Installing @oh-my-pi/pi-coding-agent..."
if ! run_with_bun bun install -g @oh-my-pi/pi-coding-agent; then
    print_error "Failed to install @oh-my-pi/pi-coding-agent."
    exit 1
fi

if ! command -v omp >/dev/null 2>&1; then
    print_error "@oh-my-pi/pi-coding-agent installed but omp was not found."
    exit 1
fi

if ! run_with_bun bun "$BUN_INSTALL/bin/omp" --version >/dev/null 2>&1; then
    print_error "omp was installed but did not start."
    exit 1
fi

source "$SETUP_DIR/apps/apm.sh"
sync_apm_agent_packages

print_success "Oh My Pi installed via Bun"
