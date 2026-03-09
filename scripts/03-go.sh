#!/bin/bash
# shellcheck source=00-core.sh
source "$SCRIPTS_DIR/00-core.sh"

print_step "Installing Go tools..."

if command -v go &> /dev/null; then
    if [ -f "$DOTFILES_DIR/Gofile" ]; then
        print_info "Installing Go packages from Gofile..."
        while IFS= read -r package || [[ -n "$package" ]]; do
            [[ "$package" =~ ^[[:space:]]*# ]] && continue  # skip comments
            [[ -z "${package// }" ]] && continue              # skip empty lines
            print_info "Installing $package..."
            if [[ "$package" == github.com/gnoverse/gnopls@* ]]; then
                GOTOOLCHAIN=go1.24.10 go install "$package"
            else
                go install "$package"
            fi
            print_success "$package installed"
        done < "$DOTFILES_DIR/Gofile"
    else
        print_info "Gofile not found, skipping Go package installation"
    fi
else
    print_info "Go not found, skipping Go tools installation"
fi
