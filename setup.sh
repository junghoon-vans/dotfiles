#!/bin/bash

# ========================================
# Dotfiles Setup Script
# ========================================
# This script automates the full development environment setup
# including Homebrew, Oh My Zsh, plugins, and all necessary tools.
#
# Usage: ./setup.sh

set -e  # Exit on error

# Colors for output
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_step() {
    echo -e "\n${CYAN}==>${NC} ${GREEN}$1${NC}"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# ========================================
# 1. Check and Install Homebrew
# ========================================
print_step "Checking Homebrew..."

if ! command -v brew &> /dev/null; then
    print_info "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_success "Homebrew installed successfully"
else
    print_success "Homebrew already installed"
fi

# ========================================
# 2. Install Homebrew Packages
# ========================================
print_step "Installing Homebrew packages..."

if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    cd "$DOTFILES_DIR"
    brew bundle install
    print_success "Homebrew packages installed"
else
    print_error "Brewfile not found!"
    exit 1
fi

# ========================================
# 3. Install Go Tools
# ========================================
print_step "Installing Go tools..."

if command -v go &> /dev/null; then
    print_info "Installing golangci-lint..."
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    print_success "golangci-lint installed"

    print_info "Installing gofumpt..."
    go install mvdan.cc/gofumpt@latest
    print_success "gofumpt installed"

    print_info "Installing gnopls..."
    go install github.com/gnoverse/gnopls@latest
    print_success "gnopls installed"
else
    print_info "Go not found, skipping Go tools installation"
fi

# ========================================
# 4. Install Oh My Zsh
# ========================================
print_step "Installing Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success "Oh My Zsh already installed"
else
    print_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
fi

# ========================================
# 5. Install Oh My Zsh Plugins
# ========================================
print_step "Installing Oh My Zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_success "zsh-autosuggestions already installed"
else
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions installed"
fi

# zsh-syntax-highlighting
if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_success "zsh-syntax-highlighting already installed"
else
    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting installed"
fi

# zsh-completions
if [ -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    print_success "zsh-completions already installed"
else
    print_info "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    print_success "zsh-completions installed"
fi

# zsh-hangul
if [ -d "$ZSH_CUSTOM/plugins/zsh-hangul" ]; then
    print_success "zsh-hangul already installed"
else
    print_info "Installing zsh-hangul..."
    git clone https://github.com/gomjellie/zsh-hangul "$ZSH_CUSTOM/plugins/zsh-hangul"
    print_success "zsh-hangul installed"
fi

# ========================================
# 6. Install Spaceship Theme
# ========================================
print_step "Installing Spaceship theme..."

if [ -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]; then
    print_success "Spaceship theme already installed"
else
    print_info "Installing Spaceship theme..."
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
    ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    print_success "Spaceship theme installed"
fi

# ========================================
# 7. Setup FZF
# ========================================
print_step "Setting up FZF..."

if [ -f "$HOME/.fzf.zsh" ]; then
    print_success "FZF already configured"
else
    print_info "Configuring FZF..."
    "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
    print_success "FZF configured"
fi

# ========================================
# 8. Install LazyVim
# ========================================
print_step "Installing LazyVim..."

if [ -d "$HOME/.config/nvim" ]; then
    print_info "Neovim config already exists, skipping LazyVim installation"
    print_info "(If you want to reinstall, backup and remove ~/.config/nvim first)"
else
    print_info "Installing LazyVim starter..."
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
    print_success "LazyVim installed"
fi

# ========================================
# 9. Install NVM and Node.js
# ========================================
print_step "Installing NVM and Node.js..."

if [ -d "$HOME/.nvm" ]; then
    print_success "NVM already installed"
else
    print_info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    # Load NVM immediately
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    print_success "NVM installed"
fi

# Install Node.js LTS if NVM is available
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if command -v node &> /dev/null; then
        print_success "Node.js already installed ($(node --version))"
    else
        print_info "Installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        print_success "Node.js LTS installed ($(node --version))"
    fi
fi

# ========================================
# 10. Install Claude Code CLI
# ========================================
print_step "Installing Claude Code CLI..."

if command -v node &> /dev/null; then
    if command -v claude &> /dev/null; then
        print_success "Claude Code already installed ($(claude --version 2>&1 || echo 'installed'))"
    else
        print_info "Installing Claude Code globally via npm..."
        npm install -g @anthropic-ai/claude-code
        print_success "Claude Code installed"
    fi
else
    print_info "Skipping Claude Code installation (Node.js not available)"
fi

# ========================================
# 11. Install SDKMAN, Java, and Kotlin
# ========================================
print_step "Installing SDKMAN, Java, and Kotlin..."

if [ -d "$HOME/.sdkman" ]; then
    print_success "SDKMAN already installed"
else
    print_info "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash

    # Load SDKMAN immediately
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

    print_success "SDKMAN installed"
fi

# Install Java and Kotlin if SDKMAN is available
if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

    # Install Java 11
    if [ -d "$HOME/.sdkman/candidates/java/11.0.25-tem" ]; then
        print_success "Java 11 already installed"
    else
        print_info "Installing Java 11..."
        echo "n" | sdk install java 11.0.28-tem
        print_success "Java 11 installed"
    fi

    # Install Java 17
    if [ -d "$HOME/.sdkman/candidates/java/17.0.13-tem" ]; then
        print_success "Java 17 already installed"
    else
        print_info "Installing Java 17..."
        echo "n" | sdk install java 17.0.13-tem
        print_success "Java 17 installed"
    fi

    # Install Java 21
    if [ -d "$HOME/.sdkman/candidates/java/21-tem" ]; then
        print_success "Java 21 already installed"
    else
        print_info "Installing Java 21..."
        echo "y" | sdk install java 21-tem
        print_success "Java 21 installed ($(java -version 2>&1 | head -n 1))"
    fi

    # Install Kotlin
    if kotlin -version 2>&1 | grep -q "Kotlin" && [ -d "$HOME/.sdkman/candidates/kotlin/current" ]; then
        print_success "Kotlin already installed ($(kotlin -version 2>&1 | head -n 1))"
    else
        print_info "Installing Kotlin..."
        sdk install kotlin
        print_success "Kotlin installed ($(kotlin -version 2>&1 | head -n 1))"
    fi
fi

# ========================================
# 12. Install Rust (Optional)
# ========================================
print_step "Installing Rust..."

if command -v rustc &> /dev/null; then
    print_success "Rust already installed ($(rustc --version))"
else
    print_info "Do you want to install Rust? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        print_success "Rust installed successfully"
    else
        print_info "Skipping Rust installation"
    fi
fi

# ========================================
# 13. Create Symlinks
# ========================================
print_step "Creating symlinks for dotfiles..."

if [ -f "$DOTFILES_DIR/link.sh" ]; then
    chmod +x "$DOTFILES_DIR/link.sh"
    "$DOTFILES_DIR/link.sh"
    print_success "Symlinks created"
else
    print_error "link.sh not found!"
    exit 1
fi

# ========================================
# Done!
# ========================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup Complete! 🎉${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC}"
echo -e "  2. Open Neovim to install plugins: ${YELLOW}nvim${NC}"
echo -e "  3. Configure your terminal font to a Nerd Font (e.g., FiraCode Nerd Font)"
echo ""
echo -e "${CYAN}Installed tools:${NC}"
echo -e "  • Oh My Zsh with plugins and Spaceship theme"
echo -e "  • Modern CLI tools (bat, eza, ripgrep, fd, etc.)"
echo -e "  • Git with custom configuration"
echo -e "  • Neovim with LazyVim"
echo -e "  • Go development environment"
if command -v node &> /dev/null; then
    echo -e "  • Node.js ($(node --version)) via NVM"
fi
if command -v claude &> /dev/null; then
    echo -e "  • Claude Code CLI"
fi
if command -v java &> /dev/null; then
    echo -e "  • Java ($(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')) via SDKMAN"
fi
if command -v kotlin &> /dev/null; then
    echo -e "  • Kotlin ($(kotlin -version 2>&1 | awk '{print $3}')) via SDKMAN"
fi
if command -v rustc &> /dev/null; then
    echo -e "  • Rust development environment"
fi
echo ""
