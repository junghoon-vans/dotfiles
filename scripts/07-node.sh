#!/bin/bash
# shellcheck source=00-core.sh
source "$SCRIPTS_DIR/00-core.sh"

print_step "Installing NVM and Node.js..."

if [ -d "$HOME/.nvm" ]; then
    print_success "NVM already installed"
else
    print_info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    print_success "NVM installed"
fi

if [ -s "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if command -v node &> /dev/null; then
        print_success "Node.js already installed ($(node --version))"
    else
        print_info "Installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        print_success "Node.js LTS installed ($(node --version))"
    fi
fi
