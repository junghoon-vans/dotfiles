#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR="$SCRIPT_DIR"
export SETUP_DIR="$SCRIPT_DIR/setup"

source "$SETUP_DIR/lib/common.sh"

command_entries() {
  local path=""

  for path in "$SETUP_DIR"/commands/*; do
    [ -f "$path" ] || continue
    basename "$path"
  done | sort
}

command_name_from_entry() {
  printf '%s\n' "$1" | sed -E 's/^[0-9]+-//'
}

command_script() {
  local command_name="$1"
  local entry=""
  local entry_name=""

  case "$command_name" in
    *[!/a-z0-9-]*|*/*|'') return 1 ;;
  esac

  for entry in "$SETUP_DIR"/commands/*; do
    [ -f "$entry" ] || continue
    entry_name="$(basename "$entry")"
    if [ "$(command_name_from_entry "$entry_name")" = "$command_name" ]; then
      printf '%s\n' "$entry"
      return 0
    fi
  done

  return 1
}

default_commands() {
  local entry_name=""

  while IFS= read -r entry_name; do
    command_name_from_entry "$entry_name"
  done < <(command_entries)
}

print_supported_commands() {
  local command_name=""

  while IFS= read -r command_name; do
    printf '  %s\n' "$command_name"
  done < <(default_commands)
}

print_help() {
  cat <<'EOF'
Usage: ./setup.sh [command...]

Supported commands:
EOF

  print_supported_commands
}

run_command() {
  local command_name="$1"
  local script

  script="$(command_script "$command_name")"
  [ -x "$script" ] || chmod +x "$script"

  print_step "Running command: $command_name"
  bash "$script"
}

main() {
  local selected_commands=()
  local raw_command=""

  if [ $# -eq 0 ]; then
    while IFS= read -r raw_command; do
      selected_commands+=("$raw_command")
    done < <(default_commands)
  else
    for raw_command in "$@"; do
      case "$raw_command" in
        -h|--help)
          print_help
          exit 0
          ;;
      esac

      if ! command_script "$raw_command" >/dev/null; then
        print_error "Unknown command: $raw_command"
        print_help
        exit 1
      fi

      selected_commands+=("$raw_command")
    done
  fi

  for raw_command in "${selected_commands[@]}"; do
    run_command "$raw_command"
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
