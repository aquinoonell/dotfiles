# dotfiles

My personal dotfiles with a unified theme switching system.

## Quick Install (New Machine)

Run this single command to set up everything on a fresh macOS machine:

```bash
curl -fsSL https://raw.githubusercontent.com/aquinoonell/dotfiles/main/bootstrap.sh | bash
```

This will:
- Install Homebrew (if needed)
- Install Kitty, Neovim, Rift, Borders, and fonts
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

### Interactive Pickers (fzf)

```bash
theme-picker        # Visual theme carousel (cached previews, like omarchy)
theme-picker --preload  # Warm preview cache on login
wallpaper           # Pick wallpaper from current theme
wallpaper --all     # Pick wallpaper from any theme
```

### Tmux Keybinding

Press `Ctrl-s t` to open the theme picker popup (browse all themes and wallpapers).

## Window manager (Rift)

[Rift](https://github.com/acsandmann/rift) is the tiling WM. It uses BSP splits with animated layout changes.

| Shortcut | Action |
|----------|--------|
| Option+Return | New Kitty window, tiled on this workspace |
| Option+H / J / K / L | Focus |
| Option+Shift+H / J / K / L | Move window; neighbor fills the other side. No neighbor: next display |
| Option+1–4 | Workspaces 1–4 |
| Option+Shift+F or Option+Shift+T | Toggle focused window as a centered floater |
| Option+F | Fullscreen inside the gaps (borders stay visible) |
| Option+Z | Toggle Rift management on the current macOS Space |
| Option+Shift+R | Reload Rift config |

Finder, Mail, Notes, Messages, Music, Obsidian, and Zoom still float. Gaps and JankyBorders are unchanged. The menu bar shows numbered square icons only for workspaces that currently have windows.

### What Gets Themed

| Component | What Changes |
|-----------|--------------|
| Kitty | Terminal colors (via `current-theme.conf`) |
| Neovim | Colorscheme |
| JankyBorders | Window border colors |
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
│   ├── theme              # Theme switcher CLI
│   ├── theme-picker       # Interactive theme browser (fzf)
│   ├── wallpaper          # Wallpaper picker
│   ├── rift-move          # Move/tile window in a direction
│   ├── borders-toggle     # JankyBorders on/off
│   └── music              # cliamp daemon controller (play/pause/next/search)
├── rift/
│   └── config.toml        # Live Rift WM config
├── themes/                # All 22 omarchy themes
│   ├── osaka-jade/
│   │   ├── colors.toml    # Color definitions
│   │   ├── backgrounds/   # Wallpapers
│   │   └── neovim.lua     # Nvim colorscheme info
│   └── ...
├── nvim/                  # Neovim config
├── .tmux.conf             # Tmux config (includes cliamp now-playing status)
├── bootstrap.sh           # One-line installer
└── install.sh             # Local installation
```

## Requirements

- macOS (tested on Sonoma+)
- [Kitty](https://sw.kovidgoyal.net/kitty/) - Terminal
- [Neovim](https://neovim.io/) - Editor
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder (for pickers)
- [Rift](https://github.com/acsandmann/rift) - Tiling WM
- [JankyBorders](https://github.com/FelixKratz/JankyBorders) - Window borders
- [cliamp](https://github.com/bjarneo/cliamp) - Terminal music player (Spotify + YouTube Music)
- [jq](https://jqlang.github.io/jq/) - JSON parser (for tmux music status)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube streaming backend for cliamp

All dependencies are auto-installed by the bootstrap script.

## Updating

```bash
cd ~/dotfiles
git pull
./install.sh
theme $(cat ~/.current-theme)  # Re-apply current theme
```

## Music (cliamp)

[cliamp](https://github.com/bjarneo/cliamp) runs as a headless daemon and is controlled via the `music` script in `bin/`. It streams from Spotify and YouTube Music using your existing credentials in `~/.config/cliamp/config.toml`.

```bash
music start          # Launch daemon, start playing Liked Music
music stop           # Stop daemon
music toggle         # Play/pause
music next           # Next track
music prev           # Previous track
music search "query" # Search YouTube and stream result
music now            # Print current track to terminal
music vol -3         # Adjust volume in dB
```

The tmux status bar shows the current track automatically (updates every 5 seconds):
```
♪ Track Name — Artist | 14:32
```

Kitty auto-starts the daemon on launch via `~/.config/kitty/startup.session`. The daemon has no UI — all control goes through the `music` command or `cliamp` IPC directly.

> **Note:** Keep `~/.config/cliamp/config.toml` out of version control — it contains your Google OAuth credentials and Spotify client secret.

## Credits

Themes from [omarchy](https://github.com/basecamp/omarchy) by Basecamp.
