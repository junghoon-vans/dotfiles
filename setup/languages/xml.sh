#!/bin/bash
# Description: Install Eclipse LemMinX XML language server.

# shellcheck source=setup/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Eclipse LemMinX XML language server..."

LEMMINX_VERSION="0.31.1"
LEMMINX_BASE_URL="https://repo.eclipse.org/content/repositories/lemminx-releases/org/eclipse/lemminx/org.eclipse.lemminx/${LEMMINX_VERSION}"
LEMMINX_JAR_NAME="org.eclipse.lemminx-${LEMMINX_VERSION}-uber.jar"
LEMMINX_INSTALL_DIR="$HOME/.local/share/lemminx"
LEMMINX_BIN_DIR="$HOME/.local/bin"
LEMMINX_JAR_PATH="$LEMMINX_INSTALL_DIR/$LEMMINX_JAR_NAME"
LEMMINX_WRAPPER_PATH="$LEMMINX_BIN_DIR/lemminx"
LEMMINX_JAR_URL="$LEMMINX_BASE_URL/$LEMMINX_JAR_NAME"

if ! command -v curl >/dev/null 2>&1; then
    print_error "curl is required to install LemMinX"
    exit 1
fi

if ! command -v mise >/dev/null 2>&1; then
    print_error "mise is required for LemMinX. Run ./setup.sh brew-packages first."
    exit 1
fi

(
    cd "$DOTFILES_DIR" || exit
    mise install java
)

mkdir -p "$LEMMINX_INSTALL_DIR" "$LEMMINX_BIN_DIR"

print_info "Downloading $LEMMINX_JAR_NAME..."
curl -fsSL -o "$LEMMINX_JAR_PATH" "$LEMMINX_JAR_URL"

checksum_file="$(mktemp)"
trap 'rm -f "$checksum_file"' EXIT

if curl -fsSL -o "$checksum_file" "$LEMMINX_JAR_URL.sha1"; then
    expected_checksum="$(tr -d '[:space:]' < "$checksum_file")"
    if [ -z "$expected_checksum" ]; then
        print_error "Downloaded LemMinX checksum is empty"
        exit 1
    fi

    if command -v shasum >/dev/null 2>&1; then
        actual_checksum="$(shasum -a 1 "$LEMMINX_JAR_PATH" | awk '{print $1}')"
        if [ "$actual_checksum" != "$expected_checksum" ]; then
            print_error "LemMinX checksum mismatch: expected $expected_checksum, got $actual_checksum"
            exit 1
        fi
        print_success "LemMinX checksum verified"
    else
        print_info "shasum not found, skipping LemMinX checksum validation"
    fi
else
    print_info "LemMinX checksum file unavailable, skipping checksum validation"
fi

cat > "$LEMMINX_WRAPPER_PATH" <<EOF
#!/bin/bash
set -euo pipefail

cd "$DOTFILES_DIR"
# shellcheck disable=SC2086
exec mise exec -- java \${LEMMINX_JAVA_OPTS:-} -jar "$LEMMINX_JAR_PATH" "\$@"
EOF

chmod +x "$LEMMINX_WRAPPER_PATH"

print_success "LemMinX installed at $LEMMINX_JAR_PATH"
print_success "lemminx wrapper created at $LEMMINX_WRAPPER_PATH"
