#!/bin/bash
# Description: Install SDKMAN, Java/Kotlin, and JVM language servers.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

print_step "Installing SDKMAN, Java, and Kotlin..."

if command -v brew >/dev/null 2>&1; then
    for formula in jdtls kotlin-language-server; do
        if brew list "$formula" >/dev/null 2>&1; then
            print_success "$formula already installed"
        else
            brew install "$formula"
            print_success "$formula installed"
        fi
    done
else
    print_info "Homebrew not found, skipping JVM language server installation"
fi

if [ -d "$HOME/.sdkman" ]; then
    print_success "SDKMAN already installed"
else
    print_info "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash

    export SDKMAN_DIR="$HOME/.sdkman"
    if [ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
        print_error "SDKMAN installer completed but $SDKMAN_DIR/bin/sdkman-init.sh was not created"
        exit 1
    fi

    set +u
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    set -u

    print_success "SDKMAN installed"
fi

java_installed() {
    find "$HOME/.sdkman/candidates/java" -maxdepth 1 -name "$1*" -type d 2>/dev/null | grep -q .
}

require_java_installed() {
    local major_version="$1"

    if ! java_installed "$major_version"; then
        print_error "Java $major_version installation did not create an SDKMAN candidate"
        exit 1
    fi
}

require_kotlin_installed() {
    if ! command -v kotlin >/dev/null 2>&1 || [ ! -d "$HOME/.sdkman/candidates/kotlin/current" ]; then
        print_error "Kotlin installation completed but kotlin is not available"
        exit 1
    fi
}

export SDKMAN_DIR="$HOME/.sdkman"
if [ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
    print_error "SDKMAN is missing $SDKMAN_DIR/bin/sdkman-init.sh"
    exit 1
fi

set +u
source "$SDKMAN_DIR/bin/sdkman-init.sh"
set -u

if ! command -v sdk >/dev/null 2>&1; then
    print_error "SDKMAN initialized but sdk command is not available"
    exit 1
fi

if java_installed "11"; then
    print_success "Java 11 already installed"
else
    print_info "Installing Java 11..."
    echo "n" | sdk install java 11.0.28-tem
    require_java_installed "11"
    print_success "Java 11 installed"
fi

if java_installed "17"; then
    print_success "Java 17 already installed"
else
    print_info "Installing Java 17..."
    echo "n" | sdk install java 17.0.13-tem
    require_java_installed "17"
    print_success "Java 17 installed"
fi

if java_installed "21"; then
    print_success "Java 21 already installed"
else
    print_info "Installing Java 21..."
    echo "y" | sdk install java 21-tem
    require_java_installed "21"
    if ! command -v java >/dev/null 2>&1; then
        print_error "Java 21 installation completed but java is not available"
        exit 1
    fi
    print_success "Java 21 installed ($(java -version 2>&1 | head -n 1))"
fi

if kotlin -version 2>&1 | grep -q "Kotlin" && [ -d "$HOME/.sdkman/candidates/kotlin/current" ]; then
    print_success "Kotlin already installed ($(kotlin -version 2>&1 | head -n 1))"
else
    print_info "Installing Kotlin..."
    sdk install kotlin
    require_kotlin_installed
    print_success "Kotlin installed ($(kotlin -version 2>&1 | head -n 1))"
fi
