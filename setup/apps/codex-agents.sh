#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Setting up Codex agents..."

CODEX_AGENTS_REF="${CODEX_AGENTS_REF:-797d73698aa32e27938ddfa76a5170f7b26aeefd}"
CODEX_AGENTS_BASE_URL="https://raw.githubusercontent.com/VoltAgent/awesome-codex-subagents/$CODEX_AGENTS_REF"

DEFAULT_CODEX_AGENTS=(
    "codebase-orchestrator|categories/09-meta-orchestration/codebase-orchestrator.toml"
    "git-workflow-manager|categories/06-developer-experience/git-workflow-manager.toml"
    "documentation-engineer|categories/06-developer-experience/documentation-engineer.toml"
    "code-reviewer|categories/04-quality-security/code-reviewer.toml"
    "debugger|categories/04-quality-security/debugger.toml"
    "test-automator|categories/04-quality-security/test-automator.toml"
    "security-auditor|categories/04-quality-security/security-auditor.toml"
    "golang-pro|categories/02-language-specialists/golang-pro.toml"
    "typescript-pro|categories/02-language-specialists/typescript-pro.toml"
    "spring-boot-engineer|categories/02-language-specialists/spring-boot-engineer.toml"
    "sql-pro|categories/02-language-specialists/sql-pro.toml"
    "kubernetes-specialist|categories/03-infrastructure/kubernetes-specialist.toml"
    "terraform-engineer|categories/03-infrastructure/terraform-engineer.toml"
    "blockchain-developer|categories/07-specialized-domains/blockchain-developer.toml"
    "mcp-developer|categories/06-developer-experience/mcp-developer.toml"
)

if ! command -v curl &> /dev/null; then
    print_error "curl is required for Codex agents setup."
    exit 1
fi

install_codex_agent() {
    local agent_spec="$1"
    local agent_name="${agent_spec%%|*}"
    local source_path="${agent_spec#*|}"
    local target_dir="$HOME/.codex/agents"
    local target_file="$target_dir/$agent_name.toml"
    local temp_file=""
    local backup_file=""
    local source_url="$CODEX_AGENTS_BASE_URL/$source_path"

    if [ "$agent_name" = "$source_path" ]; then
        print_error "Codex agent spec must use name|source-path: $agent_spec"
        exit 1
    fi

    temp_file="$(mktemp)"
    curl -fsSL "$source_url" -o "$temp_file"

    if ! grep -Eq "^name = \"$agent_name\"$" "$temp_file"; then
        print_error "Downloaded Codex agent has unexpected name: $agent_name"
        print_error "Source: $source_url"
        rm -f "$temp_file"
        exit 1
    fi

    if ! grep -Eq '^developer_instructions = """' "$temp_file"; then
        print_error "Downloaded Codex agent is missing developer_instructions: $agent_name"
        rm -f "$temp_file"
        exit 1
    fi

    mkdir -p "$target_dir"

    if [ -f "$target_file" ] && cmp -s "$temp_file" "$target_file"; then
        print_info "Codex agent already current: $agent_name"
        rm -f "$temp_file"
        return 0
    fi

    if [ -f "$target_file" ]; then
        backup_file="$target_file.backup.$(date +%Y%m%d-%H%M%S)"
        cp "$target_file" "$backup_file"
        print_info "Backed up existing Codex agent: $backup_file"
    fi

    mv "$temp_file" "$target_file"
    print_success "Codex agent installed: $agent_name"
}

for agent_spec in "${DEFAULT_CODEX_AGENTS[@]}"; do
    install_codex_agent "$agent_spec"
done
