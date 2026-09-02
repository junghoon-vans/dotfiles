#!/bin/bash

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

APM_INSTALL_DIR="${APM_INSTALL_DIR:-$HOME/.local/bin}"
APM_MCP_SERVERS="atlassian github context7 notion gnomcp firecrawl playwright aside"

install_apm() {
    if command -v apm >/dev/null 2>&1; then
        print_success "APM already installed: $(apm --version)"
        return
    fi

    print_info "Installing Agent Package Manager..."
    mkdir -p "$APM_INSTALL_DIR"
    curl --proto '=https' --tlsv1.2 -fsSL https://aka.ms/apm-unix |
        APM_INSTALL_DIR="$APM_INSTALL_DIR" sh

    if ! command -v apm >/dev/null 2>&1; then
        print_error "APM installed but was not found on PATH. Restart the shell and run ./setup.sh omp."
        exit 1
    fi

    print_success "APM installed: $(apm --version)"
}

merge_apm_codex_mcp() {
    local temp_dir=""
    local generated_config=""
    local config_dir="$HOME/.codex"
    local config_file="$config_dir/config.toml"
    local merged_file=""

    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/apm-codex.XXXXXX")"
    generated_config="$temp_dir/.codex/config.toml"
    merged_file="$temp_dir/merged.toml"

    print_info "Rendering shared MCP servers through APM..."
    (
        cd "$DOTFILES_DIR" || exit
        apm install --target codex --only mcp --root "$temp_dir"
    )

    if [ ! -s "$generated_config" ]; then
        print_error "APM did not render a Codex MCP configuration."
        rm -rf "$temp_dir"
        exit 1
    fi

    mkdir -p "$config_dir"
    touch "$config_file"
    awk -v servers="$APM_MCP_SERVERS" '
        BEGIN {
            count = split(servers, names, " ")
            for (item = 1; item <= count; item++) {
                managed[names[item]] = 1
            }
            skip = 0
        }
        /^\[/ {
            table = $0
            sub(/^\[mcp_servers\./, "", table)
            sub(/\].*$/, "", table)
            split(table, parts, ".")
            skip = (parts[1] in managed)
        }
        !skip { print }
    ' "$config_file" > "$merged_file"

    if [ -s "$merged_file" ]; then
        printf '\n' >> "$merged_file"
    fi
    cat "$generated_config" >> "$merged_file"
    cat "$merged_file" > "$config_file"
    chmod 600 "$config_file"
    rm -rf "$temp_dir"

    print_success "APM-managed MCP servers synchronized into $config_file"
}

sync_apm_agent_packages() {
    install_apm

    print_info "Syncing shared agent skills with APM..."
    (
        cd "$DOTFILES_DIR" || exit
        apm install --global --target agent-skills --only apm "$DOTFILES_DIR"
    )
    merge_apm_codex_mcp
    print_success "Shared agent packages synchronized"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    sync_apm_agent_packages
fi
