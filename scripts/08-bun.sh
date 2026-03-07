#!/bin/bash
# shellcheck source=00-core.sh
source "$SCRIPTS_DIR/00-core.sh"

print_step "Installing Bun..."

if command -v bun &> /dev/null; then
    print_success "Bun already installed ($(bun --version))"
else
    print_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    print_success "Bun installed"
fi
