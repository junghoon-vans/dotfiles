#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

for script in \
    "$SETUP_DIR/languages/go.sh" \
    "$SETUP_DIR/languages/node.sh" \
    "$SETUP_DIR/languages/bun.sh" \
    "$SETUP_DIR/languages/java.sh" \
    "$SETUP_DIR/languages/rust.sh" \
    "$SETUP_DIR/languages/python.sh"; do
    bash "$script"
done
