#!/bin/bash
# Description: Install NVM and the latest Node.js LTS runtime.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing NVM and Node.js..."

if [ -d "$HOME/.nvm" ]; then
    print_success "NVM already installed"
else
    print_info "Installing NVM..."
    nvm_version=""
    nvm_version=$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)".*/\1/' || true)
    if [ -z "$nvm_version" ]; then
        print_error "Could not determine latest NVM version"
        exit 1
    fi

    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" | bash

    export NVM_DIR="$HOME/.nvm"
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        print_error "NVM installer completed but $NVM_DIR/nvm.sh was not created"
        exit 1
    fi
    \. "$NVM_DIR/nvm.sh"

    print_success "NVM installed"
fi

export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    print_error "NVM is missing $NVM_DIR/nvm.sh"
    exit 1
fi

\. "$NVM_DIR/nvm.sh"

if command -v node &> /dev/null; then
    print_success "Node.js already installed ($(node --version))"
else
    print_info "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*
    if ! command -v node >/dev/null 2>&1; then
        print_error "Node.js LTS installation completed but node is not available"
        exit 1
    fi
    print_success "Node.js LTS installed ($(node --version))"
fi
