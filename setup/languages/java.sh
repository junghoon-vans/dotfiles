#!/bin/bash
# Description: Install SDKMAN, Java 11/17/21, and Kotlin.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing SDKMAN, Java, and Kotlin..."

if [ -d "$HOME/.sdkman" ]; then
    print_success "SDKMAN already installed"
else
    print_info "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash

    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

    print_success "SDKMAN installed"
fi

java_installed() {
    find "$HOME/.sdkman/candidates/java" -maxdepth 1 -name "$1*" -type d 2>/dev/null | grep -q .
}

if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    set +u
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    set -u

    if java_installed "11"; then
        print_success "Java 11 already installed"
    else
        print_info "Installing Java 11..."
        echo "n" | sdk install java 11.0.28-tem
        print_success "Java 11 installed"
    fi

    if java_installed "17"; then
        print_success "Java 17 already installed"
    else
        print_info "Installing Java 17..."
        echo "n" | sdk install java 17.0.13-tem
        print_success "Java 17 installed"
    fi

    if java_installed "21"; then
        print_success "Java 21 already installed"
    else
        print_info "Installing Java 21..."
        echo "y" | sdk install java 21-tem
        print_success "Java 21 installed ($(java -version 2>&1 | head -n 1))"
    fi

    if kotlin -version 2>&1 | grep -q "Kotlin" && [ -d "$HOME/.sdkman/candidates/kotlin/current" ]; then
        print_success "Kotlin already installed ($(kotlin -version 2>&1 | head -n 1))"
    else
        print_info "Installing Kotlin..."
        sdk install kotlin
        print_success "Kotlin installed ($(kotlin -version 2>&1 | head -n 1))"
    fi
fi
