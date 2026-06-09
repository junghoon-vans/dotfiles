#!/bin/bash
# Description: Install Sui CLI, Move analyzer, and local validator wrapper through suiup.

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Sui tooling..."

SUIUP_INSTALLER_URL="https://raw.githubusercontent.com/Mystenlabs/suiup/main/install.sh"
LOCAL_BIN_DIR="$HOME/.local/bin"
SUI_VERSION="${SUI_VERSION:-testnet}"
SUI_MOVE_ANALYZER_VERSION="${SUI_MOVE_ANALYZER_VERSION:-testnet}"

if ! command -v curl >/dev/null 2>&1; then
    print_error "curl is required to install Sui tooling"
    exit 1
fi

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Sui tooling. Run ./setup.sh brew-packages first."
    exit 1
fi

sync_mise_global_config

mkdir -p "$LOCAL_BIN_DIR"
prepend_path_if_dir "$LOCAL_BIN_DIR"

print_info "Installing Rust prerequisite via mise..."
(
    cd "$DOTFILES_DIR" || exit
    mise install rust
    mise exec -- rustc --version
)
print_success "Rust prerequisite installed via mise"

suiup_installer_file="$(mktemp)"
trap 'rm -f "$suiup_installer_file"' EXIT

print_info "Installing or updating suiup with the official installer..."
curl -fsSL -o "$suiup_installer_file" "$SUIUP_INSTALLER_URL"
SUIUP_INSTALL_DIR="$LOCAL_BIN_DIR" SUIUP_DEFAULT_BIN_DIR="$LOCAL_BIN_DIR" sh "$suiup_installer_file"
hash -r
print_success "suiup installed"

if [ ! -x "$LOCAL_BIN_DIR/suiup" ]; then
    print_error "suiup is not executable at $LOCAL_BIN_DIR/suiup"
    exit 1
fi

export SUIUP_DEFAULT_BIN_DIR="$LOCAL_BIN_DIR"

print_info "Installing Sui CLI with suiup (${SUI_VERSION})..."
"$LOCAL_BIN_DIR/suiup" install "sui@$SUI_VERSION" -y
print_success "Sui CLI installed"

print_info "Installing move-analyzer with suiup (${SUI_MOVE_ANALYZER_VERSION})..."
if "$LOCAL_BIN_DIR/suiup" install "move-analyzer@$SUI_MOVE_ANALYZER_VERSION" -y; then
    print_success "move-analyzer installed"
else
    print_info "move-analyzer install is not supported by this suiup version"
fi

cat > "$LOCAL_BIN_DIR/sui-test-validator" <<'EOF'
#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ]; then
    exec sui start --with-faucet --force-regenesis
fi

exec sui start "$@"
EOF

chmod +x "$LOCAL_BIN_DIR/sui-test-validator"
if [ ! -x "$LOCAL_BIN_DIR/sui-test-validator" ]; then
    print_error "sui-test-validator wrapper is not executable at $LOCAL_BIN_DIR/sui-test-validator"
    exit 1
fi

print_success "Sui tooling installed in $LOCAL_BIN_DIR"
