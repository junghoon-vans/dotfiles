#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

ASIDE_BROWSER_EXECUTABLE="${ASIDE_BROWSER_EXECUTABLE:-/Applications/Aside.app/Contents/MacOS/Aside}"

ensure_gnomcp_mcp() {
    local gnomcp_binary="$HOME/.local/bin/gnomcp"

    print_info "Ensuring gnomcp MCP is configured..."
    if codex mcp get gnomcp 2>/dev/null | grep -Fq "command: $gnomcp_binary"; then
        print_success "gnomcp MCP already configured"
    else
        codex mcp remove gnomcp >/dev/null 2>&1 || true
        codex mcp add gnomcp -- "$gnomcp_binary"
        print_success "gnomcp MCP configured"
    fi
}

ensure_atlassian_mcp() {
    print_info "Ensuring Atlassian MCP is configured..."
    if codex mcp get atlassian >/dev/null 2>&1; then
        print_success "Atlassian MCP already configured"
    else
        codex mcp add atlassian --url https://mcp.atlassian.com/v1/mcp/authv2
        print_success "Atlassian MCP configured"
    fi
}

ensure_firecrawl_mcp() {
    local launch_script='source "$HOME/.zshrc.local" 2>/dev/null || true; exec npx -y firecrawl-mcp'

    print_info "Ensuring Firecrawl MCP is configured..."
    if codex mcp get firecrawl >/dev/null 2>&1; then
        print_success "Firecrawl MCP already configured"
    else
        codex mcp add firecrawl -- /bin/zsh -lc "$launch_script"
        print_success "Firecrawl MCP configured"
        print_info "Set FIRECRAWL_API_KEY in ~/.zshrc.local before using Firecrawl MCP."
    fi
}

ensure_playwright_mcp() {
    print_info "Configuring Playwright MCP for Aside..."
    if [ ! -x "$ASIDE_BROWSER_EXECUTABLE" ]; then
        print_info "Aside browser not found at $ASIDE_BROWSER_EXECUTABLE; run ./setup.sh brew-packages before using Playwright MCP."
    fi

    codex mcp remove playwright >/dev/null 2>&1 || true
    codex mcp add playwright --env "PLAYWRIGHT_MCP_EXECUTABLE_PATH=$ASIDE_BROWSER_EXECUTABLE" -- npx -y @playwright/mcp@latest
    print_success "Playwright MCP configured for Aside"
}

print_step "Configuring Codex MCP servers..."

if ! command -v codex &> /dev/null; then
    print_error "codex is required for MCP setup. Run ./setup.sh codex first."
    exit 1
fi

ensure_gnomcp_mcp
ensure_atlassian_mcp
ensure_firecrawl_mcp
ensure_playwright_mcp
