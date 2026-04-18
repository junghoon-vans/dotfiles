#!/bin/bash

set -euo pipefail

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SETUP_DIR="${SETUP_DIR:-$DOTFILES_DIR/setup}"

detect_homebrew_prefix() {
    if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "$HOMEBREW_PREFIX" ]; then
        printf '%s\n' "$HOMEBREW_PREFIX"
        return
    fi

    if command -v brew >/dev/null 2>&1; then
        brew --prefix 2>/dev/null || true
        return
    fi

    if [ -d "/opt/homebrew" ]; then
        printf '%s\n' "/opt/homebrew"
    elif [ -d "/usr/local/Homebrew" ] || [ -d "/usr/local/Caskroom" ] || [ -x "/usr/local/bin/brew" ]; then
        printf '%s\n' "/usr/local"
    fi
}

prepend_path_if_dir() {
    local dir="$1"

    [ -d "$dir" ] || return 0

    case ":$PATH:" in
        *":$dir:"*) ;;
        *) export PATH="$dir:$PATH" ;;
    esac
}

print_step() {
    echo -e "\n${CYAN}==>${NC} ${GREEN}$1${NC}"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}
