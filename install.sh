#!/bin/bash
#
# Dotfiles Installation Script
# Creates symlinks from dotfiles repo to home directory
#

set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "Installing dotfiles from $DOTFILES_DIR"
echo ""

# Create config directories if they don't exist
mkdir -p ~/.config/nvim
mkdir -p ~/.config/aerospace

# Backup and link nvim config
if [[ -d ~/.config/nvim && ! -L ~/.config/nvim ]]; then
    echo "Backing up existing nvim config to ~/.config/nvim.backup"
    mv ~/.config/nvim ~/.config/nvim.backup
fi
rm -rf ~/.config/nvim
ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim
echo "✓ Linked nvim config"

# Backup and link wezterm config
if [[ -f ~/.wezterm.lua && ! -L ~/.wezterm.lua ]]; then
    echo "Backing up existing wezterm config to ~/.wezterm.lua.backup"
    mv ~/.wezterm.lua ~/.wezterm.lua.backup
fi
rm -f ~/.wezterm.lua
ln -sf "$DOTFILES_DIR/.wezterm.lua" ~/.wezterm.lua
echo "✓ Linked wezterm config"

# Backup and link aerospace config
if [[ -f ~/.config/aerospace/aerospace.toml && ! -L ~/.config/aerospace/aerospace.toml ]]; then
    echo "Backing up existing aerospace config"
    mv ~/.config/aerospace/aerospace.toml ~/.config/aerospace/aerospace.toml.backup
fi
rm -f ~/.config/aerospace/aerospace.toml
ln -sf "$DOTFILES_DIR/.aerospace.toml" ~/.config/aerospace/aerospace.toml
echo "✓ Linked aerospace config"

# Add bin to PATH if not already there
if ! echo "$PATH" | grep -q "$DOTFILES_DIR/bin"; then
    echo ""
    echo "Add this to your ~/.zshrc or ~/.bashrc:"
    echo ""
    echo "  export PATH=\"\$HOME/dotfiles/bin:\$PATH\""
    echo ""
fi

# Set gruvbox as default theme if no theme is set
if [[ ! -f ~/.current-theme ]]; then
    echo "gruvbox" > ~/.current-theme
    echo "✓ Set gruvbox as default theme"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  theme --list        # Show available themes"
echo "  theme osaka-jade    # Switch to osaka-jade theme"
echo "  theme gruvbox       # Switch to gruvbox theme"
