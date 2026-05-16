#!/bin/bash
# Description: Inspect host prerequisites, Brewfile state, harness tools, and managed dotfiles.

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

check_managed_target() {
    local source="$1"
    local target="$2"
    local display_path="$3"

    if [ ! -e "$source" ]; then
        print_error "Missing source: $source"
        missing=1
        return
    fi

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        print_success "$display_path managed as legacy symlink"
    elif [ -f "$target" ] && diff -q "$source" "$target" >/dev/null 2>&1; then
        print_success "$display_path managed by chezmoi"
    elif [ -e "$target" ] || [ -L "$target" ]; then
        print_info "$display_path has existing target at $target"
    else
        print_info "$display_path is not applied yet"
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
warn_command chezmoi "run ./setup.sh brew-packages before dotfiles apply"
warn_command mise "run ./setup.sh brew-packages before runtime setup"

if command -v brew >/dev/null 2>&1; then
    print_info "Checking Brewfile package state..."
    if brew bundle check --file "$DOTFILES_DIR/Brewfile" --no-upgrade >/dev/null 2>&1; then
        print_success "Brewfile dependencies are satisfied"
    else
        print_info "Brewfile dependencies are not fully installed; run ./setup.sh brew-packages"
    fi
fi

if command -v mise >/dev/null 2>&1 && [ -f "$DOTFILES_DIR/mise.toml" ]; then
    print_success "mise runtime config found"
    print_info "Install selected runtimes with ./setup.sh languages or individual language commands"
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

print_info "Checking local language server artifacts..."
for artifact_name in gopls gnopls; do
    if [ -x "$HOME/.local/bin/$artifact_name" ]; then
        print_success "$artifact_name artifact found"
    else
        case "$artifact_name" in
        gopls) print_info "$artifact_name artifact missing; run ./setup.sh go" ;;
        gnopls) print_info "$artifact_name artifact missing; run ./setup.sh gno" ;;
        esac
    fi
done

if [ -s "$HOME/.local/share/lemminx/lemminx.jar" ]; then
    print_success "lemminx.jar artifact found"
else
    print_info "lemminx.jar artifact missing; run ./setup.sh xml"
fi

if command -v mise >/dev/null 2>&1; then
    typescript_global_bin="$(mise exec bun@latest -- bun pm bin -g 2>/dev/null || true)"
    if [ -n "$typescript_global_bin" ] && [ -x "$typescript_global_bin/typescript-language-server" ]; then
        print_success "typescript-language-server artifact found"
    else
        print_info "typescript-language-server artifact missing; run ./setup.sh typescript"
    fi
fi

print_info "Checking executable LSP servers..."
for command_name in bash-language-server jdtls kotlin-language-server marksman pyright-langserver rust-analyzer terraform-ls yaml-language-server; do
    if command -v "$command_name" >/dev/null 2>&1; then
        print_success "$command_name found"
    else
        case "$command_name" in
        jdtls) print_info "$command_name missing; run ./setup.sh java" ;;
        kotlin-language-server) print_info "$command_name missing; run ./setup.sh kotlin" ;;
        pyright-langserver) print_info "$command_name missing; run ./setup.sh python" ;;
        rust-analyzer) print_info "$command_name missing; run ./setup.sh rust" ;;
        *) print_info "$command_name missing; run ./setup.sh brew-packages" ;;
        esac
    fi
done

print_info "Checking core managed dotfiles..."
check_managed_target "$DOTFILES_DIR/home/dot_zshrc" "$HOME/.zshrc" ".zshrc"
check_managed_target "$DOTFILES_DIR/home/dot_gitconfig" "$HOME/.gitconfig" ".gitconfig"
check_managed_target "$DOTFILES_DIR/home/dot_gitignore_global" "$HOME/.gitignore_global" ".gitignore_global"

if command -v chezmoi >/dev/null 2>&1; then
    print_info "Checking chezmoi source state..."
    if chezmoi --source "$DOTFILES_DIR" verify >/dev/null 2>&1; then
        print_success "chezmoi-managed files match $HOME"
    else
        print_info "chezmoi-managed files differ from $HOME; run ./setup.sh links"
    fi
fi

if [ "$missing" -ne 0 ]; then
    print_error "Doctor found missing required dependencies"
    exit 1
fi

print_success "Doctor completed"
