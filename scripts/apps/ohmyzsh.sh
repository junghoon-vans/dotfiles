#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success "Oh My Zsh already installed"
else
    print_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
fi

print_step "Installing Oh My Zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_success "zsh-autosuggestions already installed"
else
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions installed"
fi

if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_success "zsh-syntax-highlighting already installed"
else
    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting installed"
fi

if [ -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    print_success "zsh-completions already installed"
else
    print_info "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    print_success "zsh-completions installed"
fi

if [ -d "$ZSH_CUSTOM/plugins/zsh-hangul" ]; then
    print_success "zsh-hangul already installed"
else
    print_info "Installing zsh-hangul..."
    git clone https://github.com/gomjellie/zsh-hangul "$ZSH_CUSTOM/plugins/zsh-hangul"
    print_success "zsh-hangul installed"
fi

print_step "Installing Spaceship theme..."

if [ -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]; then
    print_success "Spaceship theme already installed"
else
    print_info "Installing Spaceship theme..."
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
    ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    print_success "Spaceship theme installed"
fi
