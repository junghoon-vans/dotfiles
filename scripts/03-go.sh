#!/bin/bash
# shellcheck source=00-core.sh
source "$SCRIPTS_DIR/00-core.sh"

print_step "Installing Go tools..."

if command -v go &> /dev/null; then
    print_info "Installing golangci-lint..."
    go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0
    print_success "golangci-lint installed"

    print_info "Installing gofumpt..."
    go install mvdan.cc/gofumpt@latest
    print_success "gofumpt installed"

    print_info "Installing gno..."
    go install github.com/gnolang/gno/gnovm/cmd/gno@latest
    print_success "gno installed"

    print_info "Installing gnopls..."
    go install github.com/gnoverse/gnopls@17a9aab6589fed9cef408dc6f8088768e1def6e8
    print_success "gnopls installed"
else
    print_info "Go not found, skipping Go tools installation"
fi
