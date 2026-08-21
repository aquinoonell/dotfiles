# dotfiles

My personal dotfiles with a unified theme switching system.

## Quick Install (New Machine)

Run this single command to set up everything on a fresh macOS machine:

```bash
curl -fsSL https://raw.githubusercontent.com/aquinoonell/dotfiles/main/bootstrap.sh | bash
```

This will:
- Install Homebrew (if needed)
- Install WezTerm, Neovim, AeroSpace, Borders, and fonts
- Clone this repo to `~/dotfiles`
- Set up all symlinks
- Configure your shell
- Apply the default theme

## Manual Installation

```bash
git clone https://github.com/aquinoonell/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Add to your `~/.zshrc`:

```bash
export PATH="$HOME/dotfiles/bin:$PATH"
```

## Theme Switching

Switch between 22 beautiful themes with a single command:

```bash
theme osaka-jade    # Switch to osaka-jade
theme gruvbox       # Switch to gruvbox
theme tokyo-night   # Switch to tokyo-night
theme --list        # List all themes
theme --current     # Show current theme
```

### What Gets Themed

| Component | What Changes |
|-----------|--------------|
| WezTerm | Terminal colors |
| Neovim | Colorscheme |
| AeroSpace | Window border colors |
| Desktop | Wallpaper |

### Available Themes

| Theme | Style | Theme | Style |
|-------|-------|-------|-------|
| catppuccin | Dark, pastel | nord | Dark, arctic |
| catppuccin-latte | Light, pastel | osaka-jade | Dark, jade green |
| ethereal | Dark, subtle | retro-82 | Dark, retro |
| everforest | Dark, green | ristretto | Dark, coffee |
| flexoki-light | Light, warm | rose-pine | Dark, pink |
| gruvbox | Dark, retro | solitude | Dark |
| hackerman | Dark, matrix | tokyo-night | Dark, neon |
| kanagawa | Dark, Japanese | vantablack | Dark, pure black |
| last-horizon | Dark | white | Light |
| lumon | Dark | | |
| lupine | Dark, purple | | |
| matte-black | Dark, minimal | | |
| miasma | Dark, swamp | | |

## Structure

```
~/dotfiles/
├── bin/
│   └── theme              # Theme switcher CLI
├── themes/                # All 22 omarchy themes
│   ├── osaka-jade/
│   │   ├── colors.toml    # Color definitions
│   │   ├── backgrounds/   # Wallpapers
│   │   └── neovim.lua     # Nvim colorscheme info
│   └── ...
├── templates/             # Config templates
│   ├── wezterm.lua.tmpl
│   └── aerospace.toml.tmpl
├── nvim/                  # Neovim config
├── .wezterm.lua           # WezTerm config (generated)
├── .aerospace.toml        # AeroSpace config (generated)
├── bootstrap.sh           # One-line installer
└── install.sh             # Local installation
```

## Requirements

- macOS (tested on Sonoma+)
- [WezTerm](https://wezfurlong.org/wezterm/) - Terminal
- [Neovim](https://neovim.io/) - Editor
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) - Tiling WM
- [JankyBorders](https://github.com/FelixKratz/JankyBorders) - Window borders

All dependencies are auto-installed by the bootstrap script.

## Updating

```bash
cd ~/dotfiles
git pull
./install.sh
theme $(cat ~/.current-theme)  # Re-apply current theme
```

## Credits

Themes from [omarchy](https://github.com/basecamp/omarchy) by Basecamp.
