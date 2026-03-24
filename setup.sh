#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$SCRIPT_DIR"
export SCRIPTS_DIR="$SCRIPT_DIR/scripts"

source "$SCRIPTS_DIR/lib/common.sh"

PHASE_ORDER=(
  bootstrap
  brew-packages
  languages
  links
  apps
  macos
)

phase_script() {
  case "$1" in
    bootstrap)     printf '%s\n' "$SCRIPTS_DIR/phases/10-bootstrap-homebrew.sh" ;;
    brew-packages) printf '%s\n' "$SCRIPTS_DIR/phases/20-install-brew-packages.sh" ;;
    languages)     printf '%s\n' "$SCRIPTS_DIR/phases/30-install-language-envs.sh" ;;
    links)         printf '%s\n' "$SCRIPTS_DIR/phases/40-link-dotfiles.sh" ;;
    apps)          printf '%s\n' "$SCRIPTS_DIR/phases/50-setup-apps.sh" ;;
    macos)         printf '%s\n' "$SCRIPTS_DIR/phases/60-apply-macos.sh" ;;
    *)             return 1 ;;
  esac
}

normalize_phase() {
  case "$1" in
    bootstrap|brew-packages|languages|links|apps|macos) printf '%s\n' "$1" ;;
    brew|packages) printf '%s\n' "brew-packages" ;;
    lang) printf '%s\n' "languages" ;;
    1|01) printf '%s\n' "bootstrap" ;;
    2|02) printf '%s\n' "brew-packages" ;;
    3|03) printf '%s\n' "languages" ;;
    4|04) printf '%s\n' "links" ;;
    5|05) printf '%s\n' "apps" ;;
    6|06) printf '%s\n' "macos" ;;
    *) return 1 ;;
  esac
}

print_help() {
  cat <<'EOF'
Usage: ./setup.sh [phase...]

Supported phases:
  bootstrap      Install Homebrew itself
  brew-packages  Install Brewfile packages and brew-owned fixups
  languages      Install language runtimes and ecosystem global tools
  links          Symlink tracked dotfiles into $HOME
  apps           Run app/bootstrap setup that depends on linked config
  macos          Apply macOS defaults

Short aliases:
  brew, packages, lang

Numeric aliases:
  01 bootstrap
  02 brew-packages
  03 languages
  04 links
  05 apps
  06 macos
EOF
}

run_phase() {
  local phase="$1"
  local script

  script="$(phase_script "$phase")"
  [ -x "$script" ] || chmod +x "$script"

  print_step "Running phase: $phase"
  bash "$script"
}

main() {
  local selected_phases=()
  local raw_phase=""
  local phase=""

  if [ $# -eq 0 ]; then
    selected_phases=("${PHASE_ORDER[@]}")
  else
    for raw_phase in "$@"; do
      case "$raw_phase" in
        -h|--help)
          print_help
          exit 0
          ;;
      esac

      if ! phase="$(normalize_phase "$raw_phase")"; then
        print_error "Unknown phase: $raw_phase"
        print_help
        exit 1
      fi

      selected_phases+=("$phase")
    done
  fi

  for phase in "${selected_phases[@]}"; do
    run_phase "$phase"
  done

  echo ""
  echo -e "\033[1;32m========================================\033[0m"
  echo -e "\033[1;32m  Setup Complete! 🎉\033[0m"
  echo -e "\033[1;32m========================================\033[0m"
  echo ""
  echo -e "\033[1;36mNext steps:\033[0m"
  echo -e "  1. Restart your terminal or run: \033[1;33msource ~/.zshrc\033[0m"
  echo -e "  2. Activate Gno support in Zed if needed: \033[1;33mCmd+Shift+P → 'zed: install dev extension' → ~/.local/share/zed/dev-extensions/zed-gno\033[0m"
}

main "$@"
