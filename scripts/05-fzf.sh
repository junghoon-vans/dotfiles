#!/bin/bash
# shellcheck source=00-core.sh
source "$SCRIPTS_DIR/00-core.sh"

print_step "Setting up FZF..."

if [ -f "$HOME/.fzf.zsh" ]; then
    print_success "FZF already configured"
else
    print_info "Configuring FZF..."
    "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
    print_success "FZF configured"
fi
