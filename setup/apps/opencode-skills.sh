#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Setting up OpenCode skills..."

DEFAULT_OPENCODE_SKILLS=(
    "vercel-labs/skills@find-skills"
    "vercel-labs/agent-skills@vercel-react-best-practices"
    "jeffallan/claude-skills@golang-pro"
)

if ! command -v mise &> /dev/null; then
    print_error "mise is required for OpenCode skills setup. Run ./setup.sh brew-packages first."
    exit 1
fi

if ! (cd "$DOTFILES_DIR" && mise exec -- node --version &> /dev/null 2>&1); then
    print_error "Node.js is required for OpenCode skills setup. Run ./setup.sh node first."
    exit 1
fi

install_opencode_skill() {
    local skill_spec="$1"
    local source="${skill_spec%@*}"
    local skill_name="${skill_spec##*@}"

    if [ "$source" = "$skill_name" ]; then
        print_error "OpenCode skill spec must use source@skill-name: $skill_spec"
        exit 1
    fi

    print_info "Installing OpenCode skill: $skill_spec"
    (
        cd "$DOTFILES_DIR" || exit
        mise exec -- npx --yes skills add "$source" --skill "$skill_name" --global --agent opencode --copy --yes
    )
    print_success "OpenCode skill installed: $skill_name"
}

for skill_spec in "${DEFAULT_OPENCODE_SKILLS[@]}"; do
    install_opencode_skill "$skill_spec"
done
