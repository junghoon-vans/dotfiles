#!/bin/bash
# Description: Install Java via mise plus JDTLS.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Java runtime and JDTLS..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Java. Run ./setup.sh brew-packages first."
    exit 1
fi

(
    cd "$DOTFILES_DIR" || exit
    mise install java
    mise exec -- java -version >/dev/null
)
print_success "Java runtime installed via mise"

if command -v brew >/dev/null 2>&1; then
    if brew list jdtls >/dev/null 2>&1; then
        print_success "jdtls already installed"
    else
        brew install jdtls
        print_success "jdtls installed"
    fi
else
    print_info "Homebrew not found, skipping JDTLS installation"
fi
