#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR="$SCRIPT_DIR"
export SETUP_DIR="$SCRIPT_DIR/setup"

# shellcheck source=setup/lib/common.sh
source "$SETUP_DIR/lib/common.sh"

command_entries() {
  local path=""

  for path in "$SETUP_DIR"/commands/*; do
    [ -f "$path" ] || continue
    basename "$path"
  done | sort
}

utility_commands() {
  printf '%s\n' check doctor clean-backups
}

language_commands() {
  printf '%s\n' go node bun java xml rust python gno typescript
}

command_name_from_entry() {
  printf '%s\n' "$1" | sed -E 's/^[0-9]+-//'
}

validate_command_entries() {
  local entry_name=""
  local command_name=""
  local seen_names_file=""

  seen_names_file="$(mktemp)"

  while IFS= read -r entry_name; do
    if ! printf '%s\n' "$entry_name" | grep -Eq '^[0-9][0-9]-[a-z0-9]+(-[a-z0-9]+)*$'; then
      print_error "Invalid command filename: $entry_name"
      print_error "Expected format: NN-command-name"
      exit 1
    fi

    command_name="$(command_name_from_entry "$entry_name")"
    if grep -Fxq "$command_name" "$seen_names_file"; then
      print_error "Duplicate command name: $command_name"
      exit 1
    fi

    printf '%s\n' "$command_name" >> "$seen_names_file"
  done < <(command_entries)

  rm -f "$seen_names_file"
}

command_script() {
  local command_name="$1"
  local entry_name=""

  case "$command_name" in
    ''|-*|*/*|*[!a-z0-9-]*) return 1 ;;
  esac

  if ! printf '%s\n' "$command_name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    return 1
  fi

  case "$command_name" in
    check|doctor|clean-backups)
      printf '%s\n' "$SETUP_DIR/$command_name.sh"
      return 0
      ;;
    go|node|bun|java|xml|rust|python|gno|typescript)
      printf '%s\n' "$SETUP_DIR/languages/$command_name.sh"
      return 0
      ;;
  esac

  while IFS= read -r entry_name; do
    if [ "$(command_name_from_entry "$entry_name")" = "$command_name" ]; then
      printf '%s\n' "$SETUP_DIR/commands/$entry_name"
      return 0
    fi
  done < <(command_entries)

  return 1
}

default_commands() {
  local entry_name=""

  while IFS= read -r entry_name; do
    command_name_from_entry "$entry_name"
  done < <(command_entries)
}

command_description() {
  local command_name="$1"
  local script=""
  local line=""

  if ! script="$(command_script "$command_name")"; then
    printf '%s\n' "No description available."
    return 0
  fi

  while IFS= read -r line; do
    case "$line" in
      \#\ Description:*)
        printf '%s\n' "${line#\# Description: }"
        return 0
        ;;
    esac
  done < "$script"

  printf '%s\n' "No description available."
}

print_command_entry() {
  local command_name="$1"
  printf '  %-14s %s\n' "$command_name" "$(command_description "$command_name")"
}

print_supported_commands() {
  local command_name=""

  printf 'Default commands:\n'
  while IFS= read -r command_name; do
    print_command_entry "$command_name"
  done < <(default_commands)

  printf '\nUtility commands:\n'
  while IFS= read -r command_name; do
    print_command_entry "$command_name"
  done < <(utility_commands)

  printf '\nLanguage commands:\n'
  while IFS= read -r command_name; do
    print_command_entry "$command_name"
  done < <(language_commands)

  printf '\nNotes:\n'
  printf '  %-14s %s\n' 'gno' 'Requires Go; run ./setup.sh go first on a clean host.'
  printf '  %-14s %s\n' 'xml' 'Requires Java; run ./setup.sh java first on a clean host.'
  printf '  %-14s %s\n' 'typescript' 'Requires Bun; run ./setup.sh bun first on a clean host.'
}

print_help() {
  cat <<'EOF'
Usage: ./setup.sh [option...] [command...]

Options:
  -h, --help          Show this help message
  -y, --yes           Run non-interactively and answer yes to prompts
      --no-input      Run non-interactively using each prompt's default answer
      --dry-run       Print the selected commands without running them
      --skip COMMAND  Exclude a command from the selected command list

Supported commands:
EOF

  print_supported_commands
}

run_command() {
  local command_name="$1"
  local script

  script="$(command_script "$command_name")"

  if [ "${SETUP_DRY_RUN:-0}" = "1" ]; then
    print_info "Would run command: $command_name - $(command_description "$command_name")"
    return 0
  fi

  print_info "$command_name: $(command_description "$command_name")"
  if ! confirm "Run setup command '$command_name'?" "yes"; then
    print_info "Skipped command: $command_name"
    return 0
  fi

  print_step "Running command: $command_name"
  bash "$script"
}

contains_command() {
  local needle="$1"
  shift
  local item=""

  for item in "$@"; do
    [ "$item" != "$needle" ] || return 0
  done

  return 1
}

is_utility_command() {
  local needle="$1"
  local command_name=""

  while IFS= read -r command_name; do
    [ "$command_name" != "$needle" ] || return 0
  done < <(utility_commands)

  return 1
}

selected_commands_are_utilities() {
  local command_name=""

  for command_name in "$@"; do
    if ! is_utility_command "$command_name"; then
      return 1
    fi
  done

  return 0
}

selected_commands_affect_shell() {
  local command_name=""

  for command_name in "$@"; do
    case "$command_name" in
      bootstrap|brew-packages|languages|links|apps|opencode|go|node|bun|java|xml|rust|python|gno|typescript)
        return 0
        ;;
    esac
  done

  return 1
}

selected_commands_affect_zed_gno() {
  local command_name=""

  for command_name in "$@"; do
    case "$command_name" in
      apps)
        return 0
        ;;
    esac
  done

  return 1
}

print_selected_commands() {
  local command_name=""

  for command_name in "$@"; do
    print_command_entry "$command_name"
  done
}

main() {
  local selected_commands=()
  local skipped_commands=()
  local raw_command=""

  validate_command_entries

  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        print_help
        exit 0
        ;;
      -y|--yes)
        export SETUP_YES=1
        export SETUP_NO_INPUT=1
        shift
        ;;
      --no-input)
        export SETUP_NO_INPUT=1
        shift
        ;;
      --dry-run)
        export SETUP_DRY_RUN=1
        shift
        ;;
      --skip)
        if [ $# -lt 2 ]; then
          print_error "--skip requires a command name"
          print_help
          exit 1
        fi
        if ! command_script "$2" >/dev/null; then
          print_error "Unknown command for --skip: $2"
          print_help
          exit 1
        fi
        skipped_commands+=("$2")
        shift 2
        ;;
      --skip=*)
        raw_command="${1#--skip=}"
        if ! command_script "$raw_command" >/dev/null; then
          print_error "Unknown command for --skip: $raw_command"
          print_help
          exit 1
        fi
        skipped_commands+=("$raw_command")
        shift
        ;;
      --)
        shift
        break
        ;;
      --*)
        print_error "Unknown option: $1"
        print_help
        exit 1
        ;;
      *)
        break
        ;;
    esac
  done

  if [ $# -eq 0 ]; then
    while IFS= read -r raw_command; do
      selected_commands+=("$raw_command")
    done < <(default_commands)
  else
    for raw_command in "$@"; do
      if ! command_script "$raw_command" >/dev/null; then
        print_error "Unknown command: $raw_command"
        print_help
        exit 1
      fi

      selected_commands+=("$raw_command")
    done
  fi

  if [ ${#skipped_commands[@]} -gt 0 ]; then
    local filtered_commands=()
    export SETUP_SKIP_COMMANDS=" ${skipped_commands[*]} "

    for raw_command in "${selected_commands[@]}"; do
      if contains_command "$raw_command" "${skipped_commands[@]}"; then
        print_info "Skipping command: $raw_command"
        continue
      fi
      filtered_commands+=("$raw_command")
    done

    selected_commands=()
    if [ ${#filtered_commands[@]} -gt 0 ]; then
      selected_commands=("${filtered_commands[@]}")
    fi
  fi

  if [ ${#selected_commands[@]} -eq 0 ]; then
    if [ ${#skipped_commands[@]} -gt 0 ]; then
      print_error "All selected commands were skipped: ${skipped_commands[*]}"
    else
      print_error "No setup commands selected"
    fi
    exit 1
  fi

  print_step "Selected setup commands"
  print_selected_commands "${selected_commands[@]}"

  if [ "${SETUP_DRY_RUN:-0}" = "1" ]; then
    print_success "Dry run complete"
    exit 0
  fi

  for raw_command in "${selected_commands[@]}"; do
    run_command "$raw_command"
  done

  echo ""
  echo -e "\033[1;32m========================================\033[0m"
  if selected_commands_are_utilities "${selected_commands[@]}"; then
    echo -e "\033[1;32m  Command Complete! ✓\033[0m"
    echo -e "\033[1;32m========================================\033[0m"
    return 0
  fi

  echo -e "\033[1;32m  Setup Complete! 🎉\033[0m"
  echo -e "\033[1;32m========================================\033[0m"
  echo ""
  if selected_commands_affect_shell "${selected_commands[@]}" || selected_commands_affect_zed_gno "${selected_commands[@]}"; then
    local next_step_number=1
    echo -e "\033[1;36mNext steps:\033[0m"
    if selected_commands_affect_shell "${selected_commands[@]}"; then
      echo -e "  $next_step_number. Restart your terminal or run: \033[1;33msource ~/.zshrc\033[0m"
      next_step_number=$((next_step_number + 1))
    fi
    if selected_commands_affect_zed_gno "${selected_commands[@]}"; then
      echo -e "  $next_step_number. Activate Gno support in Zed if needed: \033[1;33mCmd+Shift+P → 'zed: install dev extension' → ~/.local/share/zed/dev-extensions/zed-gno\033[0m"
    fi
  fi
}

main "$@"
