#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

for script in \
    "$SCRIPTS_DIR/languages/go.sh" \
    "$SCRIPTS_DIR/languages/node.sh" \
    "$SCRIPTS_DIR/languages/bun.sh" \
    "$SCRIPTS_DIR/languages/java.sh" \
    "$SCRIPTS_DIR/languages/rust.sh" \
    "$SCRIPTS_DIR/languages/python.sh"; do
    bash "$script"
done
