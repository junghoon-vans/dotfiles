#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Setting up Codex CLI and LazyCodex..."

ensure_codex_mcp_oauth_credentials_store() {
    local config_dir="$HOME/.codex"
    local config_file="$config_dir/config.toml"
    local tmp_file=""

    mkdir -p "$config_dir"

    if [ -f "$config_file" ] && grep -Eq '^[[:space:]]*mcp_oauth_credentials_store[[:space:]]*=' "$config_file"; then
        tmp_file="$(mktemp "${TMPDIR:-/tmp}/codex-config.XXXXXX")"
        awk '
            BEGIN { updated = 0 }
            /^[[:space:]]*mcp_oauth_credentials_store[[:space:]]*=/ {
                if (updated == 0) {
                    print "mcp_oauth_credentials_store = \"file\""
                    updated = 1
                }
                next
            }
            { print }
            END {
                if (updated == 0) {
                    print "mcp_oauth_credentials_store = \"file\""
                }
            }
        ' "$config_file" > "$tmp_file"
        cat "$tmp_file" > "$config_file"
        rm -f "$tmp_file"
    else
        if [ -s "$config_file" ]; then
            printf '\n' >> "$config_file"
        fi
        printf '%s\n' 'mcp_oauth_credentials_store = "file"' >> "$config_file"
    fi

    chmod 600 "$config_file"
}

if ! command -v mise &> /dev/null; then
    print_error "mise is required for Codex setup. Run ./setup.sh brew-packages first."
    exit 1
fi

if ! (cd "$DOTFILES_DIR" && mise exec -- node --version &> /dev/null 2>&1); then
    print_error "Node.js is required for Codex setup. Run ./setup.sh node first."
    exit 1
fi

print_info "Installing @openai/codex..."
(cd "$DOTFILES_DIR" && mise exec -- npm install -g @openai/codex)
print_success "@openai/codex installed"

print_info "Bootstrapping LazyCodex..."
(cd "$DOTFILES_DIR" && mise exec -- npx --yes lazycodex-ai install --no-tui --codex-autonomous)
print_success "LazyCodex configured"

print_info "Configuring Codex MCP OAuth credential storage..."
ensure_codex_mcp_oauth_credentials_store
print_success "Codex MCP OAuth credentials configured for file storage"

print_info "Ensuring Atlassian MCP is configured..."
if codex mcp get atlassian >/dev/null 2>&1; then
    print_success "Atlassian MCP already configured"
else
    codex mcp add atlassian --url https://mcp.atlassian.com/v1/mcp/authv2
    print_success "Atlassian MCP configured"
fi
