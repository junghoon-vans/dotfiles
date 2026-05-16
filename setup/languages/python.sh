#!/bin/bash
# Description: Install Python via mise plus pyright and ruff.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Python runtime and tooling..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Python. Run ./setup.sh brew-packages first."
    exit 1
fi

if ! command -v brew &>/dev/null; then
    print_error "Homebrew is required to install uv"
    exit 1
fi

for formula in uv pyright ruff; do
    if brew list "$formula" >/dev/null 2>&1; then
        print_success "$formula already installed"
    else
        brew install "$formula"
        print_success "$formula installed"
    fi
done

export PATH="$HOME/.local/bin:$PATH"

(
    cd "$DOTFILES_DIR" || exit
    mise install python
    mise exec -- python --version
)
print_success "Python runtime installed via mise"

pyright_langserver_path="$(resolve_tool_path "pyright-langserver" "pyright" || true)"
if [ -z "$pyright_langserver_path" ]; then
    print_error "pyright-langserver executable not found after Homebrew installation"
    exit 1
fi

create_mise_tool_path_wrapper "pyright-langserver" "$pyright_langserver_path"
print_success "pyright-langserver wrapper created in $HOME/.local/bin"
