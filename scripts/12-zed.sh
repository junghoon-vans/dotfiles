#!/bin/bash
# shellcheck source=00-core.sh
source "$SCRIPTS_DIR/00-core.sh"

print_step "Setting up Zed extensions..."

ZED_GNO_DIR="$HOME/.local/share/zed/dev-extensions/zed-gno"

if [ -d "$ZED_GNO_DIR" ]; then
    print_info "zed-gno already cloned at $ZED_GNO_DIR"
else
    print_info "Cloning zed-gno extension..."
    mkdir -p "$HOME/.local/share/zed/dev-extensions"
    git clone https://github.com/julienrbrt/zed-gno "$ZED_GNO_DIR"
    print_success "zed-gno cloned to $ZED_GNO_DIR"
fi

EXTENSION_TOML="$ZED_GNO_DIR/extension.toml"
if grep -q '^\[grammars\.gno\]' "$EXTENSION_TOML" 2>/dev/null; then
    awk '/^\[grammars\.gno\]/{skip=3} skip>0{skip--; next} 1' "$EXTENSION_TOML" > "$EXTENSION_TOML.tmp"
    mv "$EXTENSION_TOML.tmp" "$EXTENSION_TOML"
    print_success "zed-gno extension.toml patched"
fi

print_info "NOTE: To activate Gno support in Zed, run once manually:"
print_info "  1. Open Zed → Cmd+Shift+P → 'zed: install dev extension'"
print_info "  2. Select: $ZED_GNO_DIR"
