#!/bin/bash
# shellcheck source=00-core.sh
source "$SCRIPTS_DIR/00-core.sh"

print_step "Applying macOS defaults..."

# ========================================
# Dock
# ========================================
print_info "Configuring Dock..."

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Remove launch bounce animation
defaults write com.apple.dock launchanim -bool false

# Hide recent apps section
defaults write com.apple.dock show-recents -bool false

# ========================================
# Appearance
# ========================================
print_info "Configuring appearance..."

# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# ========================================
# Apply changes
# ========================================
killall Dock 2>/dev/null || true

print_success "macOS defaults applied"
