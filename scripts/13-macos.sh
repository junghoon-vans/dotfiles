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

# Remove delay and speed up hide/show animation
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4

# Remove launch bounce animation
defaults write com.apple.dock launchanim -bool false

# Hide recent apps section
defaults write com.apple.dock show-recents -bool false

# ========================================
# Finder
# ========================================
print_info "Configuring Finder..."

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar at bottom
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar at bottom
defaults write com.apple.finder ShowStatusBar -bool true

# Search in current folder by default (not entire Mac)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# No warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# ========================================
# Keyboard
# ========================================
print_info "Configuring keyboard..."

# Faster key repeat (default: 6, lower = faster)
defaults write NSGlobalDomain KeyRepeat -int 2

# Shorter delay before key repeat starts (default: 25, lower = faster)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart quotes (breaks code)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes (breaks code)
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable auto period on double-space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# ========================================
# Screenshot
# ========================================
print_info "Configuring screenshot..."

# Remove drop shadow from screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ========================================
# Appearance
# ========================================
print_info "Configuring appearance..."

# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# ========================================
# Misc
# ========================================
print_info "Configuring misc..."

# Save to local disk by default, not iCloud
# Save to local disk by default, not iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# ========================================
# Apply changes
# ========================================
killall Dock    2>/dev/null || true
killall Finder  2>/dev/null || true

print_success "macOS defaults applied"
