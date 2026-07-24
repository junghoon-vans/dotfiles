#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

ASIDE_BROWSER_EXECUTABLE="${ASIDE_BROWSER_EXECUTABLE:-/Applications/Aside.app/Contents/MacOS/Aside}"

ensure_aside_cli() {
    print_info "Checking Aside CLI..."
    if command -v aside >/dev/null 2>&1; then
        print_success "Aside CLI found"
    else
        print_info "Aside CLI missing; install it from Aside Developer settings or run: curl -fsSL https://releases.aside.com/install.sh | bash"
    fi
}

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

ensure_github_mcp() {
    print_info "Ensuring GitHub Copilot MCP is configured..."
    if codex mcp get github >/dev/null 2>&1; then
        print_success "GitHub Copilot MCP already configured"
    else
        codex mcp add github --url https://api.githubcopilot.com/mcp/ --bearer-token-env-var GITHUB_PERSONAL_ACCESS_TOKEN
        print_success "GitHub Copilot MCP configured"
        print_info "Set GITHUB_PERSONAL_ACCESS_TOKEN in ~/.zshrc.local before using GitHub Copilot MCP."
    fi
}

ensure_context7_mcp() {
    print_info "Ensuring Context7 MCP is configured..."
    if codex mcp get context7 >/dev/null 2>&1; then
        print_success "Context7 MCP already configured"
    else
        codex mcp add context7 --url https://mcp.context7.com/mcp
        print_success "Context7 MCP configured"
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

ensure_aside_mcp() {
    print_info "Ensuring native Aside MCP is configured for Codex..."
    if ! command -v aside >/dev/null 2>&1; then
        print_info "Skipping native Aside MCP because the aside CLI is missing."
        return
    fi

    if codex mcp get aside 2>/dev/null | grep -Fq "command: aside"; then
        print_success "Native Aside MCP already configured"
    else
        codex mcp remove aside >/dev/null 2>&1 || true
        codex mcp add aside -- aside mcp
        print_success "Native Aside MCP configured"
    fi
}

print_step "Configuring Codex MCP servers..."

if ! command -v codex &> /dev/null; then
    print_error "codex is required for MCP setup. Run ./setup.sh codex first."
    exit 1
fi

ensure_aside_cli
ensure_gnomcp_mcp
ensure_atlassian_mcp
ensure_github_mcp
ensure_context7_mcp
ensure_firecrawl_mcp
ensure_playwright_mcp
ensure_aside_mcp
