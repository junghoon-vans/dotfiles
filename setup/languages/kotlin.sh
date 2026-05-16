#!/bin/bash
# Description: Install Kotlin via mise plus Kotlin language server.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Kotlin runtime and language server..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Kotlin. Run ./setup.sh brew-packages first."
    exit 1
fi

(
    cd "$DOTFILES_DIR" || exit
    mise install java
    mise install kotlin
    mise exec -- kotlin -version >/dev/null
)
print_success "Java and Kotlin runtimes installed via mise"

if command -v brew >/dev/null 2>&1; then
    if brew list kotlin-language-server >/dev/null 2>&1; then
        print_success "kotlin-language-server already installed"
    else
        brew install kotlin-language-server
        print_success "kotlin-language-server installed"
    fi

    kotlin_language_server_path="$(resolve_tool_path "kotlin-language-server" "kotlin-language-server" || true)"
    if [ -z "$kotlin_language_server_path" ]; then
        print_error "kotlin-language-server executable not found after Homebrew installation"
        exit 1
    fi

    create_mise_tool_path_wrapper "kotlin-language-server" "$kotlin_language_server_path"
    print_success "kotlin-language-server wrapper created in $HOME/.local/bin"
else
    print_info "Homebrew not found, skipping Kotlin language server installation"
fi
