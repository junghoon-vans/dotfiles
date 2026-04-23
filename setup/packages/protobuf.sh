#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

TAP_NAME="junghoon/local"
FORMULA_NAME="protobuf@34.1"
FORMULA_PATH="$DOTFILES_DIR/Formula/protobuf@34.1.rb"

if [ ! -f "$FORMULA_PATH" ]; then
    print_error "Local protobuf formula not found: $FORMULA_PATH"
    exit 1
fi

if ! brew tap | grep -Fxq "$TAP_NAME"; then
    print_info "Creating local Homebrew tap $TAP_NAME..."
    brew tap-new "$TAP_NAME"
    print_success "Local Homebrew tap created"
fi

TAP_REPO="$(brew --repository "$TAP_NAME")"
TAP_FORMULA_DIR="$TAP_REPO/Formula"
TAP_FORMULA_PATH="$TAP_FORMULA_DIR/$FORMULA_NAME.rb"

mkdir -p "$TAP_FORMULA_DIR"
cp "$FORMULA_PATH" "$TAP_FORMULA_PATH"
print_success "Local protobuf formula synced to $TAP_FORMULA_PATH"

if brew list "$FORMULA_NAME" >/dev/null 2>&1; then
    print_success "$FORMULA_NAME already installed"
else
    print_info "Installing $FORMULA_NAME from local Homebrew tap..."
    brew install "$TAP_NAME/$FORMULA_NAME"
    print_success "$FORMULA_NAME installed"
fi

if brew list protobuf >/dev/null 2>&1; then
    brew unlink protobuf >/dev/null 2>&1 || true
fi

if brew list protobuf@34.0 >/dev/null 2>&1; then
    brew unlink protobuf@34.0 >/dev/null 2>&1 || true
fi

brew link --overwrite --force "$FORMULA_NAME" >/dev/null 2>&1
print_success "$FORMULA_NAME linked"
