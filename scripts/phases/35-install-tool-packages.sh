#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

for script in \
    "$SCRIPTS_DIR/packages/go.sh" \
    "$SCRIPTS_DIR/packages/bun.sh"; do
    bash "$script"
done
