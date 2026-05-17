#!/bin/bash
# Description: Install Python via mise plus pyright and ruff.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Python runtime and tooling..."

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Python. Run ./setup.sh brew-packages first."
    exit 1
fi

sync_mise_global_config

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
