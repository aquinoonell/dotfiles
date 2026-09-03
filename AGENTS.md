# Creating a theme (read this first)

This repo is a unified theme system for macOS: WezTerm, Neovim, JankyBorders, tmux popup colors, and desktop wallpaper. **Do not invent a parallel theming path.** One folder under `themes/` plus one nvim mapping is enough to theme everything.

Repo: `~/dotfiles` (also `https://github.com/aquinoonell/dotfiles`).

## Fastest path (copy this)

1. Copy an existing theme as a skeleton:
   ```bash
   cp -R ~/dotfiles/themes/ethereal ~/dotfiles/themes/<kebab-name>
   rm -f ~/dotfiles/themes/<kebab-name>/backgrounds/*
   ```
   Use `ethereal` (toml-only) unless a real nvim plugin exists. Use `gruvbox` as the plugin example.
2. Rewrite `colors.toml` (required keys below). Hex only, quoted, `#RRGGBB`.
3. Put 3–5 wallpapers in `themes/<kebab-name>/backgrounds/` named `N-short-slug.jpg` (or `.png` / `.webp`).
4. Register the theme in `nvim/lua/plugins/colorscheme.lua` (required — picker finds folders, nvim does not).
5. Verify, then apply:
   ```bash
   ~/dotfiles/bin/theme --list
   ~/dotfiles/bin/theme-preview "○ <kebab-name>"
   ~/dotfiles/bin/theme <kebab-name>
   ```

Do **not** edit `.wezterm.lua` by hand. `bin/theme` generates it from templates.

## What actually gets applied

| Surface | Source | How |
|---|---|---|
| WezTerm | `templates/wezterm.lua.tmpl` | Filled from `colors.toml` → `~/.wezterm.lua` |
| JankyBorders | `themes/<name>/colors.toml` `accent` / `muted` | Applied as `0xffRRGGBB` via borders IPC |
| Neovim | `nvim/lua/plugins/colorscheme.lua` | Live reload via `nvr` calling `OmarchyApplyTheme('<name>')`; next launch reads `~/.current-theme` |
| Desktop wallpaper | `themes/<name>/backgrounds/` | First file in glob order on theme apply; a specific file if the user picks a wallpaper row |
| Tmux popup / fzf picker chrome | `colors.toml` `background`, `foreground`, `accent`, `selection`, `muted` | Set when picker opens and when `theme` runs |
| Picker list | directory name under `themes/` | Any folder is listed; no extra registry |

Unused omarchy leftovers (skip unless asked): `vscode.json`, `hyprland.lua`, `btop.theme`, `chromium.theme`, `keyboard.rgb`, `shell.lock.toml`, `unlock.png`. `icons.theme` is Linux Yaru; keep a one-line file if copying a skeleton, it is not applied on this Mac.

`.gitignore` ignores `themes/*/*.png` and `themes/*/preview*.png` at the theme **root**. Wallpaper images belong in `backgrounds/`, not the theme root.

## Theme folder

```
themes/<kebab-name>/
├── colors.toml          # required
├── icons.theme          # optional one-liner, unused on macOS
├── neovim.lua           # optional, documentation only — live nvim uses colorscheme.lua
└── backgrounds/
    ├── 1-foo.jpg
    ├── 2-bar.webp
    └── 3-baz.png
```

**Name = directory name.** Lowercase kebab-case (`stranger-things`, not `StrangerThings`). That string is what `theme`, the picker, and `~/.current-theme` use.

## `colors.toml` (required keys)

Parser is naive: `^key = "value"` only. No tables, no comments on the same line as a key.

```toml
mode = "dark"   # or "light"

accent = "#E4141A"
selection = "#2A1016"
muted = "#7A4A55"

background = "#0C0A0F"
dark_background = "#08070B"
darker_background = "#050406"
lighter_background = "#181119"

foreground = "#E8DCE0"
dark_foreground = "#8A6C75"
light_foreground = "#F2E9EC"
bright_foreground = "#FFF3F5"

red = "#E4141A"
yellow = "#E8B33C"
orange = "#F0662B"
green = "#3FA34D"
cyan = "#2FA6A0"
blue = "#2E6FD9"
magenta = "#B0348A"
brown = "#5C2E27"

bright_red = "#FF3B3F"
bright_yellow = "#FFD166"
bright_green = "#5FD16E"
bright_cyan = "#5FD9D2"
bright_blue = "#5B96FF"
bright_magenta = "#E05CB4"
```

### How keys are consumed

Must exist or templates/borders/picker look wrong:

- `background`, `foreground`, `accent`, `selection`, `muted`
- `red` `green` `yellow` `blue` `cyan` `magenta`
- `bright_red` `bright_green` `bright_yellow` `bright_blue` `bright_cyan` `bright_magenta`

Also fill (nvim toml fallback + future-proofing): `dark_background`, `darker_background`, `lighter_background`, `dark_foreground`, `light_foreground`, `bright_foreground`, `orange`, `brown`.

`bin/theme` also derives:

- `{{THEME_NAME}}` from the folder name
- `{{accent_hex}}` / `{{muted_hex}}` from `accent` / `muted` (`#E4141A` → `0xffE4141A`)

After writing toml, confirm templates have no leftover `{{placeholders}}`:

```bash
theme=<kebab-name>
for tmpl in ~/dotfiles/templates/*.tmpl; do
  grep -o '{{[a-z_]*}}' "$tmpl" | tr -d '{}' | sort -u | while read -r key; do
    case $key in THEME_NAME|accent_hex|muted_hex) continue ;; esac
    grep -q "^$key = " ~/dotfiles/themes/$theme/colors.toml || echo "MISSING $key in $tmpl"
  done
done
```

### Palette rules that match the rest of the system

- **Dark themes:** near-black `background`, light `foreground`, one saturated `accent`. `selection` slightly lighter than background. `muted` readable on background (borders + comments).
- **Light themes:** copy `white` / `flexoki-light`. Set `mode = "light"` and nvim `bg = "light"`.
- ANSI `red`…`magenta` should look like the wallpapers (e.g. Christmas-bulb colors for Stranger Things), not a generic rainbow.
- WezTerm maps ansi black → `background`, ansi white → `muted`, bright white → `foreground`. Keep those relationships or the terminal will look wrong.
- Contrast: accent/red/green/yellow must be readable on `background`.

Reference palettes: `themes/ethereal/colors.toml` (toml-only dark), `themes/gruvbox/colors.toml` (plugin dark), `themes/flexoki-light/colors.toml` (plugin light).

## Neovim registration (the step that is easy to miss)

Picker auto-discovers folders. **Neovim does not.** Edit `nvim/lua/plugins/colorscheme.lua`.

### Default: no plugin (fastest, no lazy.nvim errors)

Add to `theme_configs`:

```lua
["<kebab-name>"] = { plugin = nil, colorscheme = nil, bg = "dark" },
```

Use this unless a well-known, installable nvim colorscheme exists. `OmarchyApplyTheme` will build highlights from `colors.toml`. `neovim.lua` in the theme folder is unused at runtime.

### Optional: dedicated plugin

Only if the plugin is real and you will add it to the lazy spec.

1. `theme_configs`:
   ```lua
   ["<kebab-name>"] = { plugin = "user/repo.nvim", colorscheme = "<vim-colorscheme-name>", bg = "dark" },
   ```
2. Same file, `return { ... }` plugin list — **exact repo string** as `plugin`:
   ```lua
   { "user/repo.nvim", lazy = true },
   ```
3. Optional `themes/<kebab-name>/neovim.lua` for humans; live reload still uses `theme_configs`.

**Never** `lazy.load({ plugins = { "<colorscheme>" } })` by the vim colorscheme name. `gruvbox` ≠ plugin id `gruvbox.nvim`. Load by matching `plug[1] == config.plugin`. If the plugin fails to load, fall back to `apply_from_toml` — do not `vim.cmd.colorscheme("gruvbox")` as a last resort unless that plugin is already loaded (that was the `Plugin gruvbox not found` bug).

After adding a plugin, restart nvim once so lazy installs it. Toml-only themes do not need a restart of nvim for the *definition*, but live reload still needs nvim running with `nvr`.

## Wallpapers

- Put files in `themes/<kebab-name>/backgrounds/` only.
- Extensions: `.jpg` `.jpeg` `.png` `.webp`.
- Names: `N-short-slug.ext` so they sort in the picker (`1-alphabet-wall.jpg`).
- `theme <name>` sets wallpaper to the first glob match (`*.jpg` then jpeg/png/webp — not numeric order). If the default should be a specific image, prefix it so it sorts first **and** prefer `.jpg` as `1-…jpg`, or tell the user to pick the wallpaper row.
- Selecting a picker row `  theme/file.jpg` runs `theme <name>` then sets that file via osascript.
- Prefer original generated art (16:9, dark negative space, no logos/wordmarks) over ripping copyrighted stills.
- Keep each file roughly 200–800 KB. Convert with:
  ```bash
  sips -s format jpeg -s formatOptions 90 in.png --out themes/<name>/backgrounds/1-slug.jpg
  ```
- 3–5 images is enough. `wallpaper` / `wallpaper --all` also list these files.

`theme-picker` preview is **color swatches only** (no image render in fzf). Do not add chafa/imgcat to the preview path unless the user asks — kitty/iterm graphics do not show in fzf, and `--symbols all` breaks FiraMono Nerd Font (`U+1FBxx`).

## Apply / verify

```bash
# listed?
~/dotfiles/bin/theme --list | grep <kebab-name>

# swatches from toml
~/dotfiles/bin/theme-preview "○ <kebab-name>"
~/dotfiles/bin/theme-preview "  <kebab-name>/1-slug.jpg"

# apply everything
~/dotfiles/bin/theme <kebab-name>

# picker (tmux: Ctrl-s t)
theme-picker
```

`theme` writes `~/.current-theme`, regenerates WezTerm, updates `borders` via IPC (and writes `~/.config/borders/bordersrc` so brew-service restarts stay themed), sets wallpaper, updates tmux popup colors, and pokes running nvim via `nvr`. If `~/.borders-disabled` exists, borders are skipped.

Do not apply a theme just to test files unless the user wants their desktop changed.

## Do not

- Use `pkill borders` from theme scripts or tmux popups — JankyBorders supports IPC updates, and `pkill` races Homebrew's KeepAlive launchd service. Use `borders active_color=... inactive_color=...` to recolor a running instance.
- Hand-edit generated `~/.wezterm.lua` as the source of truth.
- Add a theme only in nvim plugins, or only as a folder with no `colorscheme.lua` mapping.
- Scrape official show/movie stills into `backgrounds/` (copyright). Generate original images in the same aesthetic.
- Use spaces or uppercase in the theme directory name.
- Put wallpapers next to `colors.toml`; they will not show in the picker and root `*.png` is gitignored.
- Require `chafa` for the picker.
- Commit unless the user asks.

## Checklist

- [ ] `themes/<kebab-name>/colors.toml` with all keys above
- [ ] `themes/<kebab-name>/backgrounds/N-slug.{jpg,png,webp}`
- [ ] `theme_configs` entry in `nvim/lua/plugins/colorscheme.lua`
- [ ] Plugin spec added **only** if `plugin` is not nil
- [ ] Template placeholder check passes
- [ ] `theme --list` shows the name
- [ ] User asked to apply / commit before you do either
