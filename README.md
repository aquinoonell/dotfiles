# dotfiles

My personal dotfiles with a unified theme switching system.

## Installation

```bash
git clone https://github.com/aquinoonell/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then add to your `~/.zshrc`:

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

- **WezTerm** - Terminal colors
- **Neovim** - Colorscheme
- **AeroSpace** - Window border colors
- **Desktop** - Wallpaper

### Available Themes

All themes from [omarchy](https://github.com/basecamp/omarchy/tree/main/themes):

| Theme | Style |
|-------|-------|
| catppuccin | Dark, pastel |
| catppuccin-latte | Light, pastel |
| ethereal | Dark, subtle |
| everforest | Dark, green |
| flexoki-light | Light, warm |
| gruvbox | Dark, retro |
| hackerman | Dark, matrix |
| kanagawa | Dark, Japanese |
| last-horizon | Dark |
| lumon | Dark |
| lupine | Dark, purple |
| matte-black | Dark, minimal |
| miasma | Dark, swamp |
| nord | Dark, arctic |
| osaka-jade | Dark, jade green |
| retro-82 | Dark, retro |
| ristretto | Dark, coffee |
| rose-pine | Dark, pink |
| solitude | Dark |
| tokyo-night | Dark, neon |
| vantablack | Dark, pure black |
| white | Light |

## Structure

```
~/dotfiles/
├── bin/
│   └── theme              # Theme switcher CLI
├── themes/                # All 22 omarchy themes
│   ├── osaka-jade/
│   ├── gruvbox/
│   └── ...
├── templates/             # Config templates
│   ├── wezterm.lua.tmpl
│   └── aerospace.toml.tmpl
├── nvim/                  # Neovim config
├── .wezterm.lua           # Generated WezTerm config
├── .aerospace.toml        # Generated AeroSpace config
└── install.sh             # Installation script
```

## Configs

- **nvim** - Neovim with lazy.nvim, LSP, Treesitter, Telescope
- **wezterm** - Terminal with dynamic theming
- **aerospace** - Tiling window manager with themed borders
