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

# Ensure bun is available in current session
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Install global bun packages from Bunfile
if [ -f "$DOTFILES_DIR/Bunfile" ]; then
    print_step "Installing global bun packages from Bunfile..."
    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ "$package" =~ ^[[:space:]]*# ]] && continue  # skip comments
        [[ -z "${package// }" ]] && continue              # skip empty lines
        print_info "Installing $package..."
        bun install -g "$package"
        print_success "$package installed"
    done < "$DOTFILES_DIR/Bunfile"
fi

# oh-my-opencode: run install step after global package is in place
if command -v bunx &> /dev/null; then
    print_step "Setting up oh-my-opencode..."
    bunx oh-my-opencode install --no-tui --claude=no --openai=yes --gemini=no --copilot=no
    print_success "oh-my-opencode configured"
fi
