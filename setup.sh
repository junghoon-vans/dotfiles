#!/bin/bash

# ========================================
# Dotfiles Setup Script
# ========================================
# Composition of modular scripts
#
# Usage: 
#   ./setup.sh           # Run all steps
#   ./setup.sh 01 03     # Run specific steps

set -euo pipefail

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
    for script in "$SCRIPT_DIR"/scripts/[0-9][0-9]-*.sh; do
        [ -f "$script" ] || continue
        prefix=$(basename "$script" | cut -c1-2)
        run_scripts "$prefix"
    done

    echo ""
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;32m  Setup Complete! 🎉\033[0m"
    echo -e "\033[1;32m========================================\033[0m"
    echo ""
    echo -e "\033[1;36mNext steps:\033[0m"
    echo -e "  1. Restart your terminal or run: \033[1;33msource ~/.zshrc\033[0m"
    echo -e "  2. Open Neovim to install plugins: \033[1;33mnvim\033[0m"
    echo -e "  3. Activate Gno support in Zed: \033[1;33mCmd+Shift+P → 'zed: install dev extension' → ~/.local/share/zed/dev-extensions/zed-gno\033[0m"
else
    for arg in "$@"; do
        run_scripts "$arg"
    done
fi
