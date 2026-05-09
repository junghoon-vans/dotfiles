#!/bin/bash
# Description: Install Solana CLI and Anchor tooling.

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Solana and Anchor tooling..."

SOLANA_INSTALLER_URL="https://release.anza.xyz/stable/install"
SOLANA_ACTIVE_BIN_DIR="$HOME/.local/share/solana/install/active_release/bin"
LOCAL_BIN_DIR="$HOME/.local/bin"
CARGO_BIN_DIR="${CARGO_HOME:-$HOME/.cargo}/bin"
AVM_BIN_DIR="${AVM_HOME:-$HOME/.avm}/bin"
ANCHOR_VERSION="${ANCHOR_VERSION:-latest}"

if ! command -v curl >/dev/null 2>&1; then
    print_error "curl is required to install Solana CLI"
    exit 1
fi

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required to install Solana and Anchor tooling. Run ./setup.sh brew-packages first."
    exit 1
fi

prepend_path_if_dir "$SOLANA_ACTIVE_BIN_DIR"
prepend_path_if_dir "$CARGO_BIN_DIR"
prepend_path_if_dir "$AVM_BIN_DIR"

print_info "Installing Rust prerequisite via mise..."
(
    cd "$DOTFILES_DIR" || exit
    mise install rust
    mise exec -- rustc --version
)
print_success "Rust prerequisite installed via mise"

if [ -x "$SOLANA_ACTIVE_BIN_DIR/agave-install" ]; then
    print_info "Updating existing Solana CLI active release..."
    "$SOLANA_ACTIVE_BIN_DIR/agave-install" update
else
    solana_installer_file="$(mktemp)"
    trap 'rm -f "$solana_installer_file"' EXIT

    print_info "Downloading Anza Agave installer..."
    curl -fsSL -o "$solana_installer_file" "$SOLANA_INSTALLER_URL"
    sh "$solana_installer_file"
fi
prepend_path_if_dir "$SOLANA_ACTIVE_BIN_DIR"
print_success "Solana CLI installed"

if [ ! -x "$CARGO_BIN_DIR/avm" ]; then
    print_info "Installing Anchor Version Manager via Cargo..."
    (
        cd "$DOTFILES_DIR" || exit
        mise exec -- cargo install --git https://github.com/solana-foundation/anchor avm --force
    )
    prepend_path_if_dir "$CARGO_BIN_DIR"
    hash -r
    print_success "Anchor Version Manager installed"
else
    print_success "Anchor Version Manager already installed"
fi

print_info "Installing Anchor CLI with AVM (${ANCHOR_VERSION})..."
"$CARGO_BIN_DIR/avm" install "$ANCHOR_VERSION"
"$CARGO_BIN_DIR/avm" use "$ANCHOR_VERSION"
prepend_path_if_dir "$AVM_BIN_DIR"
print_success "Anchor CLI installed"

mkdir -p "$LOCAL_BIN_DIR"

cat > "$LOCAL_BIN_DIR/solana" <<'EOF'
#!/bin/bash
set -euo pipefail

exec "$HOME/.local/share/solana/install/active_release/bin/solana" "$@"
EOF

cat > "$LOCAL_BIN_DIR/agave-install" <<'EOF'
#!/bin/bash
set -euo pipefail

exec "$HOME/.local/share/solana/install/active_release/bin/agave-install" "$@"
EOF

cat > "$LOCAL_BIN_DIR/cargo-build-sbf" <<'EOF'
#!/bin/bash
set -euo pipefail

exec "$HOME/.local/share/solana/install/active_release/bin/cargo-build-sbf" "$@"
EOF

cat > "$LOCAL_BIN_DIR/avm" <<'EOF'
#!/bin/bash
set -euo pipefail

CARGO_BIN_DIR="${CARGO_HOME:-$HOME/.cargo}/bin"
exec "$CARGO_BIN_DIR/avm" "$@"
EOF

cat > "$LOCAL_BIN_DIR/anchor" <<'EOF'
#!/bin/bash
set -euo pipefail

AVM_BIN_DIR="${AVM_HOME:-$HOME/.avm}/bin"
exec "$AVM_BIN_DIR/anchor" "$@"
EOF

for wrapper_name in solana agave-install cargo-build-sbf avm anchor; do
    chmod +x "$LOCAL_BIN_DIR/$wrapper_name"
    if [ ! -x "$LOCAL_BIN_DIR/$wrapper_name" ]; then
        print_error "$wrapper_name wrapper is not executable at $LOCAL_BIN_DIR/$wrapper_name"
        exit 1
    fi
done

print_success "Solana and Anchor wrappers created in $LOCAL_BIN_DIR"
