local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font_size = 14

config.color_scheme = "catppuccin frappe"

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.6
config.macos_window_background_blur = 10

return config
