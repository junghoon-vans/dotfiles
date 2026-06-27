#!/bin/bash
# Description: Reconfigure Codex MCP servers without reinstalling Codex.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SETUP_DIR/.." && pwd)"
export DOTFILES_DIR SETUP_DIR

bash "$SETUP_DIR/apps/codex-mcp.sh"
