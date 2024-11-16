#!/bin/bash

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

# Check for required commands
if ! command -v stow >/dev/null 2>&1; then
    echo "Error: stow is not installed. Please install it first."
    exit 1
fi

# Configuration
DOTFILES_REPO="git@github.com:rileyjhardy/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
PACKAGES=("zsh" "nvim" "git")

# Clone or update dotfiles repository
if [ ! -d "$DOTFILES_DIR" ]; then
    print_status "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    print_status "Updating existing dotfiles repository..."
    cd "$DOTFILES_DIR"
    git pull
fi

# Stow packages
cd "$DOTFILES_DIR"
for package in "${PACKAGES[@]}"; do
    print_status "Stowing $package configuration..."
    stow -R --target="$HOME" "$package"
done

print_status "Dotfiles setup completed successfully!"

# See https://www.jakewiesler.com/blog/managing-dotfiles for implementation details