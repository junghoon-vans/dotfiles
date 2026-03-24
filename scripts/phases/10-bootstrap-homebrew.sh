#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Checking Homebrew..."

if ! command -v brew &> /dev/null; then
    print_info "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ $(uname -m) == 'arm64' ]]; then
        grep -F 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$HOME/.zprofile" >/dev/null 2>&1 || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_success "Homebrew installed successfully"
else
    print_success "Homebrew already installed"
fi
