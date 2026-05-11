#!/bin/bash

set -euo pipefail

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SETUP_DIR="${SETUP_DIR:-$DOTFILES_DIR/setup}"
SETUP_YES="${SETUP_YES:-0}"
SETUP_NO_INPUT="${SETUP_NO_INPUT:-0}"
SETUP_DRY_RUN="${SETUP_DRY_RUN:-0}"

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

create_local_bin_wrapper() {
    local tool_name="$1"
    local wrapper_dir="${2:-$HOME/.local/bin}"
    local wrapper_path="$wrapper_dir/$tool_name"

    mkdir -p "$wrapper_dir"

    cat > "$wrapper_path"

    chmod +x "$wrapper_path"
    if [ ! -x "$wrapper_path" ]; then
        print_error "$tool_name wrapper is not executable at $wrapper_path"
        exit 1
    fi
}

configure_mise_go_bin() {
    mkdir -p "$HOME/.local/bin"
    (
        cd "$DOTFILES_DIR" || exit
        mise exec -- go env -w GOBIN="$HOME/.local/bin"
    )
}

create_mise_bun_global_tool_wrapper() {
    local tool_name="$1"
    local wrapper_dir="${2:-$HOME/.local/bin}"

    create_local_bin_wrapper "$tool_name" "$wrapper_dir" <<EOF
#!/bin/bash
set -euo pipefail

cd "$DOTFILES_DIR"

tool_bin="\$(mise exec -- bun pm bin -g)"
tool_path="\$tool_bin/$tool_name"
if [ ! -x "\$tool_path" ]; then
    printf '%s\n' "$tool_name is not executable at \$tool_path" >&2
    exit 1
fi

exec mise exec -- "\$tool_path" "\$@"
EOF
}

create_mise_tool_path_wrapper() {
    local tool_name="$1"
    local tool_path="$2"
    local wrapper_dir="${3:-$HOME/.local/bin}"

    create_local_bin_wrapper "$tool_name" "$wrapper_dir" <<EOF
#!/bin/bash
set -euo pipefail

cd "$DOTFILES_DIR"

tool_path="$tool_path"
if [ ! -x "\$tool_path" ]; then
    printf '%s\n' "$tool_name is not executable at \$tool_path" >&2
    exit 1
fi

exec mise exec -- "\$tool_path" "\$@"
EOF
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

confirm() {
    local prompt="$1"
    local default_answer="${2:-yes}"
    local answer=""
    local suffix="[Y/n]"

    case "$default_answer" in
        yes|y|Y|YES)
            default_answer="yes"
            suffix="[Y/n]"
            ;;
        no|n|N|NO)
            default_answer="no"
            suffix="[y/N]"
            ;;
        *)
            print_error "Invalid confirm default: $default_answer"
            return 1
            ;;
    esac

    if [ "${SETUP_YES:-0}" = "1" ]; then
        print_info "$prompt $suffix yes (--yes)"
        return 0
    fi

    if [ "${SETUP_NO_INPUT:-0}" = "1" ] || [ ! -t 0 ]; then
        print_info "$prompt $suffix $default_answer (default)"
        [ "$default_answer" = "yes" ]
        return $?
    fi

    while true; do
        read -r -p "$(printf '%b' "${YELLOW}→${NC} $prompt $suffix ")" answer
        if [ -z "$answer" ]; then
            answer="$default_answer"
        fi

        case "$answer" in
            y|Y|yes|YES) return 0 ;;
            n|N|no|NO) return 1 ;;
            *) print_info "Please answer yes or no." ;;
        esac
    done
}
