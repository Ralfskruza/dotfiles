#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

echo "Setting up the DOTFILES"

echo "Updating system..."
sudo apt update && sudo apt upgrade -y


# 2.Installing packages

echo "Installing packages..."

# List of packages to install
PACKAGES=(
    "vim"
    "gh"
    "curl"
    "wget"
    "btop"
    "neovim"
    "fzf"
    "eza"
    "build-essential"
    "python3"
    "python3-pip"
    "python3-venv"
)

# Install packages
echo "Installing packages..."

sudo apt install -y "${PACKAGES[@]}"


DOTFILES_DIR="$HOME/DOTFILES" 

REPO_URL="https://github.com/Ralfskruza/dotfiles.git"