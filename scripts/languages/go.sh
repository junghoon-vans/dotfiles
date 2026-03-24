#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Go tools..."

if command -v go &> /dev/null; then
    if [ -f "$DOTFILES_DIR/Gofile" ]; then
        print_info "Installing Go packages from Gofile..."
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue
            package=$(awk '{print $1}' <<< "$line")
            toolchain=$(grep -o 'GOTOOLCHAIN=[^ ]*' <<< "$line" | cut -d= -f2 || true)
            if [[ -n "$toolchain" ]]; then
                print_info "Installing $package (GOTOOLCHAIN=$toolchain)..."
                GOTOOLCHAIN="$toolchain" go install "$package"
            else
                print_info "Installing $package..."
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
