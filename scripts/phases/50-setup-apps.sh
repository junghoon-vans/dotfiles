#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

for script in \
    "$SCRIPTS_DIR/apps/ohmyzsh.sh" \
    "$SCRIPTS_DIR/apps/opencode.sh" \
    "$SCRIPTS_DIR/apps/zed.sh"; do
    bash "$script"
done
