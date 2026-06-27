#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Setting up Codex CLI and LazyCodex..."

GNOMCP_REF="${GNOMCP_REF:-align-gno-interrealm-skill}"
GNOMCP_REPO="${GNOMCP_REPO:-junghoon-vans/gno-mcp}"
GNOMCP_BINARY="$HOME/.local/bin/gnomcp"
GNOMCP_RELEASE_VERSION="${GNOMCP_RELEASE_VERSION:-v0.8.0}"
GNOMCP_PLUGIN_VERSION="${GNOMCP_PLUGIN_VERSION:-${GNOMCP_REF#v}}"
GNOMCP_PLUGIN_SLOT="${GNOMCP_PLUGIN_SLOT:-${GNOMCP_PLUGIN_VERSION//\//-}}"
GNOMCP_MARKETPLACE_ROOT="$HOME/.codex/plugins/cache/gnoverse"
GNOMCP_REPO_DIR="$GNOMCP_MARKETPLACE_ROOT/gno-mcp/$GNOMCP_PLUGIN_SLOT"
GNOMCP_INSTALL_REF_FILE="$HOME/.local/share/gnomcp/install-ref"
CODEX_HUD_REPO="${CODEX_HUD_REPO:-fwyc0573/codex-hud}"
CODEX_HUD_REF="${CODEX_HUD_REF:-main}"
CODEX_HUD_DIR="${CODEX_HUD_DIR:-$HOME/.local/share/codex-hud}"

ensure_codex_mcp_oauth_credentials_store() {
    local config_dir="$HOME/.codex"
    local config_file="$config_dir/config.toml"
    local tmp_file=""

    mkdir -p "$config_dir"

    if [ -f "$config_file" ] && grep -Eq '^[[:space:]]*mcp_oauth_credentials_store[[:space:]]*=' "$config_file"; then
        tmp_file="$(mktemp "${TMPDIR:-/tmp}/codex-config.XXXXXX")"
        awk '
            BEGIN { updated = 0 }
            /^[[:space:]]*mcp_oauth_credentials_store[[:space:]]*=/ {
                if (updated == 0) {
                    print "mcp_oauth_credentials_store = \"file\""
                    updated = 1
                }
                next
            }
            { print }
            END {
                if (updated == 0) {
                    print "mcp_oauth_credentials_store = \"file\""
                }
            }
        ' "$config_file" > "$tmp_file"
        cat "$tmp_file" > "$config_file"
        rm -f "$tmp_file"
    else
        if [ -s "$config_file" ]; then
            printf '\n' >> "$config_file"
        fi
        printf '%s\n' 'mcp_oauth_credentials_store = "file"' >> "$config_file"
    fi

    chmod 600 "$config_file"
}

gnomcp_release_asset() {
    case "$(uname -s) $(uname -m)" in
    "Darwin arm64") printf '%s\n' "gno-mcp_darwin_arm64.tar.gz" ;;
    "Darwin x86_64") printf '%s\n' "gno-mcp_darwin_amd64.tar.gz" ;;
    "Linux arm64" | "Linux aarch64") printf '%s\n' "gno-mcp_linux_arm64.tar.gz" ;;
    "Linux x86_64") printf '%s\n' "gno-mcp_linux_amd64.tar.gz" ;;
    *)
        print_error "Unsupported platform for gnomcp release asset: $(uname -s) $(uname -m)"
        exit 1
        ;;
    esac
}

sha256_file() {
    local file="$1"

    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | awk '{print $1}'
    else
        print_error "sha256sum or shasum is required to verify gnomcp downloads"
        exit 1
    fi
}

install_gnomcp_binary() {
    local asset=""
    local base_url=""
    local tmp_dir=""
    local archive=""
    local checksums=""
    local expected=""
    local actual=""
    local source_revision=""

    if [ "$GNOMCP_REPO" != "gnoverse/gno-mcp" ] || [ "$GNOMCP_REF" != "$GNOMCP_RELEASE_VERSION" ]; then
        ensure_gnomcp_source_checkout
        source_revision="$(git -C "$GNOMCP_REPO_DIR" rev-parse HEAD)"

        if [ -x "$GNOMCP_BINARY" ] &&
            [ -f "$GNOMCP_INSTALL_REF_FILE" ] &&
            [ "$(cat "$GNOMCP_INSTALL_REF_FILE")" = "$GNOMCP_REPO@$source_revision" ]; then
            print_success "gnomcp $GNOMCP_REPO@$source_revision already installed at $GNOMCP_BINARY"
            return
        fi

        print_info "Building gnomcp from $GNOMCP_REPO@$GNOMCP_REF..."
        mkdir -p "$(dirname "$GNOMCP_BINARY")" "$(dirname "$GNOMCP_INSTALL_REF_FILE")"
        (cd "$GNOMCP_REPO_DIR" && mise exec -- go build -o "$GNOMCP_BINARY" ./cmd/gnomcp)
        printf '%s\n' "$GNOMCP_REPO@$source_revision" > "$GNOMCP_INSTALL_REF_FILE"
        print_success "gnomcp built at $GNOMCP_BINARY"
        return
    fi

    asset="$(gnomcp_release_asset)"
    base_url="https://github.com/$GNOMCP_REPO/releases/download/$GNOMCP_RELEASE_VERSION"
    tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/gnomcp.XXXXXX")"
    archive="$tmp_dir/$asset"
    checksums="$tmp_dir/checksums.txt"

    if [ -x "$GNOMCP_BINARY" ] && [ "$("$GNOMCP_BINARY" version 2>/dev/null || true)" = "${GNOMCP_RELEASE_VERSION#v}" ]; then
        print_success "gnomcp $GNOMCP_RELEASE_VERSION already installed at $GNOMCP_BINARY"
        return
    fi

    print_info "Installing gnomcp $GNOMCP_RELEASE_VERSION..."
    curl --proto '=https' --tlsv1.2 -fsSL "$base_url/$asset" -o "$archive"
    curl --proto '=https' --tlsv1.2 -fsSL "$base_url/checksums.txt" -o "$checksums"

    expected="$(awk -v asset="$asset" '$2 == asset { print $1 }' "$checksums")"
    if [ -z "$expected" ]; then
        print_error "No checksum found for $asset"
        rm -rf "$tmp_dir"
        exit 1
    fi

    actual="$(sha256_file "$archive")"
    if [ "$actual" != "$expected" ]; then
        print_error "gnomcp checksum mismatch for $asset"
        rm -rf "$tmp_dir"
        exit 1
    fi

    tar -xzf "$archive" -C "$tmp_dir" gnomcp
    mkdir -p "$(dirname "$GNOMCP_BINARY")"
    install -m 0755 "$tmp_dir/gnomcp" "$GNOMCP_BINARY"
    rm -rf "$tmp_dir"

    print_success "gnomcp installed at $GNOMCP_BINARY"
}

ensure_gnomcp_source_checkout() {
    local repo_url="https://github.com/$GNOMCP_REPO.git"

    mkdir -p "$(dirname "$GNOMCP_REPO_DIR")"

    if [ -d "$GNOMCP_REPO_DIR/.git" ]; then
        git -C "$GNOMCP_REPO_DIR" remote set-url origin "$repo_url"
        git -C "$GNOMCP_REPO_DIR" fetch --tags --prune origin
    elif [ -e "$GNOMCP_REPO_DIR" ]; then
        print_error "$GNOMCP_REPO_DIR exists but is not a git checkout"
        exit 1
    else
        git clone "$repo_url" "$GNOMCP_REPO_DIR"
    fi

    if git -C "$GNOMCP_REPO_DIR" rev-parse --verify --quiet "refs/remotes/origin/$GNOMCP_REF" >/dev/null; then
        git -C "$GNOMCP_REPO_DIR" checkout -B "$GNOMCP_REF" "origin/$GNOMCP_REF"
    else
        git -C "$GNOMCP_REPO_DIR" checkout --force "$GNOMCP_REF"
    fi
}

ensure_gnomcp_codex_plugin() {
    local marketplace_file="$GNOMCP_MARKETPLACE_ROOT/.agents/plugins/marketplace.json"

    print_info "Ensuring gnomcp Codex plugin marketplace..."
    mkdir -p "$(dirname "$marketplace_file")"
    ensure_gnomcp_source_checkout

    cat > "$marketplace_file" <<EOF
{
  "name": "gnoverse",
  "plugins": [
    {
      "name": "gnomcp",
      "source": {
        "source": "local",
        "path": "./gno-mcp/$GNOMCP_PLUGIN_VERSION"
      }
    }
  ]
}
EOF

    codex plugin marketplace add "$GNOMCP_MARKETPLACE_ROOT" >/dev/null
    codex plugin add gnomcp@gnoverse >/dev/null
    print_success "gnomcp Codex plugin installed"
}

ensure_codex_hud_checkout() {
    local repo_url="https://github.com/$CODEX_HUD_REPO.git"

    mkdir -p "$(dirname "$CODEX_HUD_DIR")"

    if [ -d "$CODEX_HUD_DIR/.git" ]; then
        git -C "$CODEX_HUD_DIR" remote set-url origin "$repo_url"
        git -C "$CODEX_HUD_DIR" fetch --tags --prune origin
    elif [ -e "$CODEX_HUD_DIR" ]; then
        print_error "$CODEX_HUD_DIR exists but is not a git checkout"
        exit 1
    else
        git clone "$repo_url" "$CODEX_HUD_DIR"
    fi

    if git -C "$CODEX_HUD_DIR" rev-parse --verify --quiet "refs/remotes/origin/$CODEX_HUD_REF" >/dev/null; then
        git -C "$CODEX_HUD_DIR" checkout -B "$CODEX_HUD_REF" "origin/$CODEX_HUD_REF"
    else
        git -C "$CODEX_HUD_DIR" checkout --force "$CODEX_HUD_REF"
    fi
}

write_codex_hud_command() {
    local command_name="$1"
    local source_path="$2"
    local target_path="$HOME/.local/bin/$command_name"

    cat > "$target_path" <<EOF
#!/bin/bash
exec "$source_path" "\$@"
EOF
    chmod 0755 "$target_path"
}

install_codex_hud() {
    print_info "Installing Codex HUD..."

    if ! command -v tmux >/dev/null 2>&1; then
        print_error "tmux is required for Codex HUD. Run ./setup.sh brew-packages first."
        exit 1
    fi

    ensure_codex_hud_checkout
    (cd "$CODEX_HUD_DIR" && mise exec -- npm install && mise exec -- npm run build)

    chmod +x \
        "$CODEX_HUD_DIR/bin/codex-hud" \
        "$CODEX_HUD_DIR/bin/codex-hud-install" \
        "$CODEX_HUD_DIR/bin/codex-hud-sync" \
        "$CODEX_HUD_DIR/bin/codex-hud-upgrade" \
        "$CODEX_HUD_DIR/bin/codex-hud-uninstall"

    if [ -f "$CODEX_HUD_DIR/bin/codex-hud-resize" ]; then
        chmod +x "$CODEX_HUD_DIR/bin/codex-hud-resize"
    fi

    mkdir -p "$HOME/.local/bin"
    write_codex_hud_command "codex-hud" "$CODEX_HUD_DIR/bin/codex-hud"
    write_codex_hud_command "codex-hud-install" "$CODEX_HUD_DIR/bin/codex-hud-install"
    write_codex_hud_command "codex-hud-sync" "$CODEX_HUD_DIR/bin/codex-hud-sync"
    write_codex_hud_command "codex-hud-upgrade" "$CODEX_HUD_DIR/bin/codex-hud-upgrade"
    write_codex_hud_command "codex-hud-uninstall" "$CODEX_HUD_DIR/bin/codex-hud-uninstall"
    print_success "Codex HUD installed"
}

if ! command -v mise &> /dev/null; then
    print_error "mise is required for Codex setup. Run ./setup.sh brew-packages first."
    exit 1
fi

if ! (cd "$DOTFILES_DIR" && mise exec -- node --version &> /dev/null 2>&1); then
    print_error "Node.js is required for Codex setup. Run ./setup.sh node first."
    exit 1
fi

print_info "Installing @openai/codex..."
(cd "$DOTFILES_DIR" && mise exec -- npm install -g @openai/codex)
print_success "@openai/codex installed"

print_info "Bootstrapping LazyCodex..."
(cd "$DOTFILES_DIR" && mise exec -- npx --yes lazycodex-ai install --no-tui --codex-autonomous)
print_success "LazyCodex configured"

install_codex_hud

print_info "Configuring Codex MCP OAuth credential storage..."
ensure_codex_mcp_oauth_credentials_store
print_success "Codex MCP OAuth credentials configured for file storage"

install_gnomcp_binary
ensure_gnomcp_codex_plugin
bash "$SETUP_DIR/apps/codex-mcp.sh"
