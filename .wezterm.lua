local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Gruvbox Dark (Medium contrast) color scheme
config.colors = {
    foreground = "#ebdbb2", -- Gruvbox fg
    background = "#282828", -- Gruvbox bg0 (medium contrast, matches nvim)
    cursor_bg = "#ebdbb2",
    cursor_fg = "#1d2021",
    cursor_border = "#ebdbb2",
    selection_bg = "#504945", -- Gruvbox bg2
    selection_fg = "#ebdbb2",

    -- ANSI colors
    ansi = {
        "#282828", -- black   (bg0)
        "#cc241d", -- red
        "#98971a", -- green
        "#d79921", -- yellow
        "#458588", -- blue
        "#b16286", -- magenta/purple
        "#689d6a", -- cyan/aqua
        "#a89984", -- white   (fg4)
    },
    brights = {
        "#928374", -- bright black  (gray)
        "#fb4934", -- bright red
        "#b8bb26", -- bright green
        "#fabd2f", -- bright yellow
        "#83a598", -- bright blue
        "#d3869b", -- bright magenta/purple
        "#8ec07c", -- bright cyan/aqua
        "#ebdbb2", -- bright white  (fg)
    },
}

-- Font configuration (Fira Mono Nerd Font - matches gruvbox repo screenshot)
config.font = wezterm.font("FiraMono Nerd Font Mono", { weight = "Regular" })
config.font_size = 13.0
config.line_height = 1.0
config.freetype_load_target = "Light"
config.force_reverse_video_cursor = true

-- Snap window dimensions to exact cell boundaries so no fractional pixel
-- gap appears between the orange AeroSpace border and Neovim's tabline/statusline
config.adjust_window_size_when_changing_font_size = false

-- Configure tabs (hide them for cleaner look)
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

-- Slight transparency (as requested)
config.window_background_opacity = 0.93
config.macos_window_background_blur = 8

-- Cursor settings (blinking block like classic terminals)
config.cursor_blink_rate = 500
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Window customizations
config.window_decorations = "RESIZE"

-- Padding (none, so content reaches the screen edges)
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

config.enable_wayland = false

return config
