#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

echo "🚀 Setting up the DOTFILES"

echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

# 1. Installing packages
echo "📦 Installing core packages..."

# Added 'zsh' to the list so everything else actually works!
PACKAGES=(
"zsh"
"vim"
"gh"
"curl"
"wget"
"btop"
"neovim"
"fzf"
"build-essential"
"python3"
"python3-pip"
"python3-venv"
)

sudo apt install -y "${PACKAGES[@]}"

# Modern Ubuntu/Debian versions might need a custom repo for eza.
# This safely checks if eza exists, and installs it via official channels if missing.
if ! command -v eza &> /dev/null; then
echo "📥 Installing eza wrapper/repo..."
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza
fi

echo "✅ Packages installed successfully."

# 2. Clone/Update Dotfiles
DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/KratosGOW69/dotfiles.git"

if [ -d "$DOTFILES_DIR" ]; then
echo "📂 DOTFILES directory already exists. Pulling latest changes..."
cd "$DOTFILES_DIR"
git pull origin main
else
echo "📥 Cloning DOTFILES repository..."
git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# 3. Installing Oh My Zsh
# Using --unattended keeps the installer from hijacking the script execution flow
if [ ! -d "$HOME/.oh-my-zsh" ]; then
echo "🪄 Installing Oh My Zsh (Unattended)..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
echo "✅ Oh My Zsh already installed."
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Plugins for Zsh
echo "🔌 Downloading plugins for Zsh..."

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
echo " Downloading zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
echo " ✅ zsh-autosuggestions already installed."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
echo " Downloading zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
echo " ✅ zsh-syntax-highlighting already installed."
fi

# Powerlevel10k theme for Zsh
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
echo "🎨 Downloading Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
echo "✅ Powerlevel10k already installed."
fi

# 4. Creating symbolic links for configuration files
echo "🔗 Creating symbolic links..."

create_symlink() {
local source_file="$1"
local target_file="$2"

if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
echo "🎒 Backing up $target_file -> ${target_file}.backup"
mv "$target_file" "${target_file}.backup"
fi
ln -sf "$source_file" "$target_file"
echo "👍 Symbolic link $target_file installed."
}

# Link your .zshrc from the repository
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Change default shell to Zsh safely using sudo since chsh defaults to interactive mode
CURRENT_SHELL=$(basename "$SHELL")
ZSH_PATH=$(which zsh)

if [ "$CURRENT_SHELL" != "zsh" ]; then
echo "🔄 Changing default shell to Zsh..."
sudo chsh -s "$ZSH_PATH" "$USER"
fi

echo "🎉 setup.sh completed successfully!"
echo "Please close your terminal and open a new one to enjoy your setup."