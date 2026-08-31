#!/bin/bash

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
source "$SETUP_DIR/apps/apm.sh"

print_step "Configuring shared agent skills..."
sync_apm_agent_packages
