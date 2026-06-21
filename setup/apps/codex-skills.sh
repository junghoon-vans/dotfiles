#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Setting up Codex skills..."

DEFAULT_CODEX_SKILLS=(
    "dietrichgebert/ponytail@ponytail"
    "vercel-labs/skills@find-skills"
    "vercel-labs/agent-skills@vercel-react-best-practices"
    "jeffallan/claude-skills@golang-pro"
)

if ! command -v mise &> /dev/null; then
    print_error "mise is required for Codex skills setup. Run ./setup.sh brew-packages first."
    exit 1
fi

if ! (cd "$DOTFILES_DIR" && mise exec -- node --version &> /dev/null 2>&1); then
    print_error "Node.js is required for Codex skills setup. Run ./setup.sh node first."
    exit 1
fi

install_codex_skill() {
    local skill_spec="$1"
    local source="${skill_spec%@*}"
    local skill_name="${skill_spec##*@}"

    if [ "$source" = "$skill_name" ]; then
        print_error "Codex skill spec must use source@skill-name: $skill_spec"
        exit 1
    fi

    print_info "Installing Codex skill: $skill_spec"
    (
        cd "$DOTFILES_DIR" || exit
        mise exec -- npx --yes skills add "$source" --skill "$skill_name" --global --agent codex --copy --yes
    )
    print_success "Codex skill installed: $skill_name"
}

for skill_spec in "${DEFAULT_CODEX_SKILLS[@]}"; do
    install_codex_skill "$skill_spec"
done
