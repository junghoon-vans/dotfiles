#!/bin/bash
# Description: Install Gno from ~/gno and gnopls using mise-managed Go.

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Gno tooling..."

GNO_REF="${GNO_REF:-959cefd916021d3a55e9b51f20d05ef618e7f357}"

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required for Gno tooling. Run ./setup.sh brew-packages first."
    exit 1
fi

sync_mise_global_config

(
    cd "$DOTFILES_DIR" || exit
    mise install go
)
print_success "Go runtime installed via mise"

configure_mise_go_bin
print_success "Go install target set to $HOME/.local/bin"

if [ -d "$HOME/gno/.git" ]; then
    print_info "Updating github.com/gnolang/gno at $HOME/gno..."
    git -C "$HOME/gno" fetch --tags --prune origin
elif [ -e "$HOME/gno" ]; then
    print_error "$HOME/gno exists but is not a git checkout"
    exit 1
else
    print_info "Cloning github.com/gnolang/gno to $HOME/gno..."
    git clone https://github.com/gnolang/gno "$HOME/gno"
fi

print_info "Checking out github.com/gnolang/gno at $GNO_REF..."
git -C "$HOME/gno" checkout --force --detach "$GNO_REF"

print_info "Installing Gno from $HOME/gno..."
(
    cd "$HOME/gno" || exit
    mise exec -- make install
)
print_success "gno installed"

print_info "Installing github.com/gnoverse/gnopls@latest..."
(
    cd "$DOTFILES_DIR" || exit
    mise exec -- go install github.com/gnoverse/gnopls@latest
)
print_success "gnopls installed"
