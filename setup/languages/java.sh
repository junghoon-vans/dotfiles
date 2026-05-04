#!/bin/bash
# Description: Install Java and Kotlin via mise plus JVM language servers.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Java runtime and JVM tooling..."

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

(
    cd "$DOTFILES_DIR" || exit
    mise install kotlin
    mise exec -- kotlin -version >/dev/null
)
print_success "Kotlin runtime installed via mise"

if command -v brew >/dev/null 2>&1; then
    for formula in jdtls kotlin-language-server; do
        if brew list "$formula" >/dev/null 2>&1; then
            print_success "$formula already installed"
        else
            brew install "$formula"
            print_success "$formula installed"
        fi
    done
else
    print_info "Homebrew not found, skipping JVM language server installation"
fi
