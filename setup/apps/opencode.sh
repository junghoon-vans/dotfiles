#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

print_step "Setting up OpenCode, oh-my-openagent, and opencode-status-hud..."

if ! command -v bun &> /dev/null; then
    print_error "Bun is required for OpenCode setup. Run ./setup.sh bun first."
    exit 1
fi

print_info "Installing opencode-ai..."
if ! bun install -g --trust opencode-ai; then
    print_error "Failed to install trusted opencode-ai package."
    exit 1
fi
if ! opencode --version >/dev/null; then
    print_error "opencode-ai installed but OpenCode did not start."
    exit 1
fi
print_success "opencode-ai installed with trusted postinstall"

print_info "Installing OmniRoute AI gateway..."
bun install -g omniroute
print_success "OmniRoute installed"

OMNIROUTE_PLIST="$HOME/Library/LaunchAgents/com.dotfiles.omniroute.plist"
OMNIROUTE_LABEL="com.dotfiles.omniroute"
if [ -f "$OMNIROUTE_PLIST" ] && command -v launchctl &> /dev/null; then
    print_info "Loading OmniRoute LaunchAgent..."
    launchctl bootout "gui/$(id -u)" "$OMNIROUTE_PLIST" >/dev/null 2>&1 || true
    launchctl bootstrap "gui/$(id -u)" "$OMNIROUTE_PLIST"
    launchctl enable "gui/$(id -u)/$OMNIROUTE_LABEL"
    print_success "OmniRoute LaunchAgent loaded"
else
    print_info "OmniRoute LaunchAgent plist not found or launchctl unavailable; skipping (run ./setup.sh links first)"
fi

print_info "Installing oh-my-openagent..."
bun install -g oh-my-openagent
print_success "oh-my-openagent installed"

print_info "Installing opencode-status-hud..."
bun install -g opencode-status-hud
print_success "opencode-status-hud installed"

bunx oh-my-openagent install --no-tui --claude=no --openai=yes --gemini=no --copilot=no
print_success "oh-my-openagent configured"

opencode-status-hud install
print_success "opencode-status-hud configured"
