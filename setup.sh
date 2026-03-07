#!/bin/bash

# ========================================
# Dotfiles Setup Script
# ========================================
# Composition of modular scripts
#
# Usage: 
#   ./setup.sh           # Run all steps
#   ./setup.sh 01 03     # Run specific steps

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPTS_DIR="$SCRIPT_DIR/scripts"
export DOTFILES_DIR="$SCRIPT_DIR"

run_scripts() {
    local scripts=("$SCRIPT_DIR"/scripts/"$1"-*.sh)
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            source "$script"
        fi
    done
}

if [ $# -eq 0 ]; then
    run_scripts 00
    run_scripts 01
    run_scripts 02
    run_scripts 03
    run_scripts 04
    run_scripts 05
    run_scripts 06
    run_scripts 07
    run_scripts 08
    run_scripts 09
    run_scripts 10
    run_scripts 11

    echo ""
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;32m  Setup Complete! 🎉\033[0m"
    echo -e "\033[1;32m========================================\033[0m"
    echo ""
    echo -e "\033[1;36mNext steps:\033[0m"
    echo -e "  1. Restart your terminal or run: \033[1;33msource ~/.zshrc\033[0m"
    echo -e "  2. Open Neovim to install plugins: \033[1;33mnvim\033[0m"
    echo -e "  3. Configure your terminal font to a Nerd Font (e.g., FiraCode Nerd Font)"
else
    for arg in "$@"; do
        run_scripts "$arg"
    done
fi
