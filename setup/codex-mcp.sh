#!/bin/bash
# Description: Synchronize shared Codex and Oh My Pi agent packages through APM.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SETUP_DIR/.." && pwd)"
export DOTFILES_DIR SETUP_DIR

bash "$SETUP_DIR/apps/codex-mcp.sh"
