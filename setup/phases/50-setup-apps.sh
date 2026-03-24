#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

for script in \
    "$SETUP_DIR/apps/ohmyzsh.sh" \
    "$SETUP_DIR/apps/opencode.sh" \
    "$SETUP_DIR/apps/zed.sh"; do
    bash "$script"
done
