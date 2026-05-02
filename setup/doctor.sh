#!/bin/bash
# Description: Inspect host prerequisites, Brewfile state, harness tools, and symlinks.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SETUP_DIR/.." && pwd)"
export DOTFILES_DIR SETUP_DIR

# shellcheck source=setup/lib/common.sh
source "$SETUP_DIR/lib/common.sh"

missing=0

warn_command() {
    local command_name="$1"
    local hint="$2"

    if command -v "$command_name" >/dev/null 2>&1; then
        print_success "$command_name found"
    else
        print_info "$command_name missing — $hint"
    fi
}

require_command() {
    local command_name="$1"
    local hint="$2"

    if command -v "$command_name" >/dev/null 2>&1; then
        print_success "$command_name found"
    else
        print_error "$command_name missing — $hint"
        missing=1
    fi
}

check_link_target() {
    local relative_path="$1"
    local source="$DOTFILES_DIR/$relative_path"
    local target="$HOME/$relative_path"

    if [ ! -e "$source" ]; then
        print_error "Missing source: $source"
        missing=1
        return
    fi

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        print_success "$relative_path linked"
    elif [ -e "$target" ] || [ -L "$target" ]; then
        print_info "$relative_path has existing target at $target"
    else
        print_info "$relative_path is not linked yet"
    fi
}

print_step "Running dotfiles doctor..."

if [ "$(uname -s)" = "Darwin" ]; then
    print_success "macOS detected ($(sw_vers -productVersion 2>/dev/null || printf 'unknown'))"
else
    print_info "Non-macOS host detected; some setup commands are macOS-specific"
fi

require_command git "install Git or run ./setup.sh bootstrap"
require_command bash "install Bash"
warn_command python3 "run ./setup.sh python before Python-based checks"
warn_command ruby "install Ruby before Brewfile syntax checks"
warn_command brew "run ./setup.sh bootstrap before brew-managed setup"

if command -v brew >/dev/null 2>&1; then
    print_info "Checking Brewfile package state..."
    if brew bundle check --file "$DOTFILES_DIR/Brewfile" --no-upgrade >/dev/null 2>&1; then
        print_success "Brewfile dependencies are satisfied"
    else
        print_info "Brewfile dependencies are not fully installed; run ./setup.sh brew-packages"
    fi
fi

print_info "Checking common harness tools..."
for command_name in actionlint shellcheck shfmt yamlfmt; do
    if command -v "$command_name" >/dev/null 2>&1; then
        print_success "$command_name found"
    else
        print_info "$command_name missing; run ./setup.sh brew-packages"
    fi
done

print_info "Checking language-owned tools..."
for command_name in ruff biome; do
    if command -v "$command_name" >/dev/null 2>&1; then
        print_success "$command_name found"
    else
        case "$command_name" in
            ruff) print_info "$command_name missing; run ./setup.sh python" ;;
            biome) print_info "$command_name missing; run ./setup.sh typescript" ;;
        esac
    fi
done

print_info "Checking core symlink targets..."
check_link_target ".zshrc"
check_link_target ".gitconfig"
check_link_target ".gitignore_global"

if [ "$missing" -ne 0 ]; then
    print_error "Doctor found missing required dependencies"
    exit 1
fi

print_success "Doctor completed"
