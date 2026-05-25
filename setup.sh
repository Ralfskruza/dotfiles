```bash
#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

echo "🚀 Setting up DOTFILES..."

# ---------------------------------------------------------
# Update system
# ---------------------------------------------------------
echo "📦 Updating system..."
sudo apt update && sudo apt upgrade -y

# ---------------------------------------------------------
# Install packages
# ---------------------------------------------------------
echo "📦 Installing packages..."

PACKAGES=(
    "vim"
    "git"
    "zsh"
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

sudo apt install -y "${PACKAGES[@]}"

# ---------------------------------------------------------
# Variables
# ---------------------------------------------------------
DOTFILES_DIR="$HOME/DOTFILES"
REPO_URL="https://github.com/Ralfskruza/dotfiles.git"

# ---------------------------------------------------------
# Clone dotfiles repo
# ---------------------------------------------------------
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "✅ Dotfiles repository already exists."
fi

# ---------------------------------------------------------
# Install Oh My Zsh
# ---------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📥 Installing Oh My Zsh..."

    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ---------------------------------------------------------
# Install Zsh plugins
# ---------------------------------------------------------
echo "🔌 Installing Zsh plugins..."

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "📥 Downloading zsh-autosuggestions..."
    git clone \
        https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions already installed."
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "📥 Downloading zsh-syntax-highlighting..."
    git clone \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "✅ zsh-syntax-highlighting already installed."
fi

# ---------------------------------------------------------
# Install Powerlevel10k
# ---------------------------------------------------------
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
    echo "📥 Downloading Powerlevel10k..."
    git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "$P10K_DIR"
else
    echo "✅ Powerlevel10k already installed."
fi

# ---------------------------------------------------------
# Create symbolic links
# ---------------------------------------------------------
echo "🔗 Creating symbolic links..."

create_symlink() {
    local source_file="$1"
    local target_file="$2"

    # Backup existing file if it exists and isn't a symlink
    if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
        echo "📦 Backing up $target_file -> ${target_file}.backup"
        mv "$target_file" "${target_file}.backup"
    fi

    ln -sf "$source_file" "$target_file"
    echo "✅ Symlinked $target_file"
}

# ---------------------------------------------------------
# Link .zshrc
# ---------------------------------------------------------
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
else
    echo "❌ ERROR: .zshrc not found in $DOTFILES_DIR"
    exit 1
fi

# ---------------------------------------------------------
# Change default shell to Zsh
# ---------------------------------------------------------
ZSH_PATH="$(command -v zsh)"

if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "🔄 Changing default shell to Zsh..."
    chsh -s "$ZSH_PATH"
else
    echo "✅ Zsh is already the default shell."
fi

# ---------------------------------------------------------
# Done
# ---------------------------------------------------------
echo ""
echo "🎉 setup.sh completed successfully!"
echo "⚠️ Restart your terminal or run:"
echo "exec zsh"
```
