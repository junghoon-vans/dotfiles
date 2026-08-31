#!/bin/bash

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
source "$SETUP_DIR/apps/apm.sh"

print_step "Configuring shared Codex and Oh My Pi agent packages..."
sync_apm_agent_packages
