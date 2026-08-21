#!/bin/bash
#
# Dotfiles Bootstrap Script
# Run this on a fresh machine to set up everything:
#
#   curl -fsSL https://raw.githubusercontent.com/aquinoonell/dotfiles/main/bootstrap.sh | bash
#
# Or clone and run locally:
#
#   git clone https://github.com/aquinoonell/dotfiles.git ~/dotfiles && ~/dotfiles/bootstrap.sh
#

set -e

DOTFILES_REPO="https://github.com/aquinoonell/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "\n${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║     Dotfiles Bootstrap Installer          ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Check for required tools
print_step "Checking prerequisites..."

check_command() {
    if command -v "$1" &>/dev/null; then
        print_success "$1 found"
        return 0
    else
        print_warning "$1 not found"
        return 1
    fi
}

# Check git
if ! check_command git; then
    print_error "Git is required. Please install it first."
    exit 1
fi

# Check for Homebrew on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    if ! check_command brew; then
        print_step "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Clone or update dotfiles
print_step "Setting up dotfiles..."

if [[ -d "$DOTFILES_DIR" ]]; then
    print_warning "Dotfiles directory exists, pulling latest..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    print_success "Cloning dotfiles..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Install dependencies on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    print_step "Installing macOS dependencies..."
    
    # Essential tools
    brew list wezterm &>/dev/null || brew install --cask wezterm
    brew list neovim &>/dev/null || brew install neovim
    brew list neovim-remote &>/dev/null || brew install neovim-remote
    brew list tmux &>/dev/null || brew install tmux
    brew list fzf &>/dev/null || brew install fzf
    brew list borders &>/dev/null || brew install FelixKratz/formulae/borders
    brew list aerospace &>/dev/null || brew install --cask nikitabobko/tap/aerospace
    
    # Fonts
    brew list --cask font-fira-mono-nerd-font &>/dev/null || brew install --cask font-fira-mono-nerd-font
    
    print_success "Dependencies installed"
fi

# Run install script
print_step "Running install script..."
cd "$DOTFILES_DIR"
chmod +x install.sh
./install.sh

# Add bin to PATH in shell config
print_step "Configuring shell..."

add_to_path() {
    local shell_rc="$1"
    local path_line='export PATH="$HOME/dotfiles/bin:$PATH"'
    
    if [[ -f "$shell_rc" ]]; then
        if ! grep -q 'dotfiles/bin' "$shell_rc"; then
            echo "" >> "$shell_rc"
            echo "# Dotfiles" >> "$shell_rc"
            echo "$path_line" >> "$shell_rc"
            print_success "Added dotfiles/bin to PATH in $shell_rc"
        else
            print_success "PATH already configured in $shell_rc"
        fi
    fi
}

add_to_path "$HOME/.zshrc"
add_to_path "$HOME/.bashrc"

# Set default theme
print_step "Setting up theme..."

if [[ ! -f "$HOME/.current-theme" ]]; then
    echo "gruvbox" > "$HOME/.current-theme"
    print_success "Set gruvbox as default theme"
fi

# Apply current theme
export PATH="$DOTFILES_DIR/bin:$PATH"
if [[ -f "$HOME/.current-theme" ]]; then
    current=$(cat "$HOME/.current-theme")
    print_success "Applying theme: $current"
    theme "$current" 2>/dev/null || true
fi

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║     Installation Complete!                ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or run: source ~/.zshrc)"
echo "  2. Open WezTerm for the themed terminal"
echo "  3. Switch themes: theme --list"
echo ""
echo "Enjoy your new setup! 🎨"
