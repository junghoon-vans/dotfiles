#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

for script in \
    "$SETUP_DIR/packages/go.sh" \
    "$SETUP_DIR/packages/bun.sh"; do
    bash "$script"
done
