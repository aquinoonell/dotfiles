-- Dynamic colorscheme loader for theme switcher
-- Reads ~/.current-theme and applies the matching neovim colorscheme

local function read_theme()
    local file = io.open(os.getenv("HOME") .. "/.current-theme", "r")
    if file then
        local theme = file:read("*l")
        file:close()
        return theme
    end
    return nil
end

-- Theme name -> { plugin, colorscheme, background }
local theme_configs = {
    ["osaka-jade"] = { plugin = "ribru17/bamboo.nvim", colorscheme = "bamboo", bg = "dark" },
    ["gruvbox"] = { plugin = "ellisonleao/gruvbox.nvim", colorscheme = "gruvbox", bg = "dark" },
    ["tokyo-night"] = { plugin = "folke/tokyonight.nvim", colorscheme = "tokyonight-night", bg = "dark" },
    ["catppuccin"] = { plugin = "catppuccin/nvim", colorscheme = "catppuccin", bg = "dark" },
    ["catppuccin-latte"] = { plugin = "catppuccin/nvim", colorscheme = "catppuccin-latte", bg = "light" },
    ["rose-pine"] = { plugin = "rose-pine/neovim", colorscheme = "rose-pine", bg = "dark" },
    ["nord"] = { plugin = "shaunsingh/nord.nvim", colorscheme = "nord", bg = "dark" },
    ["kanagawa"] = { plugin = "rebelot/kanagawa.nvim", colorscheme = "kanagawa", bg = "dark" },
    ["everforest"] = { plugin = "sainnhe/everforest", colorscheme = "everforest", bg = "dark" },
    ["flexoki-light"] = { plugin = "kepano/flexoki-neovim", colorscheme = "flexoki-light", bg = "light" },
    ["hackerman"] = { plugin = "bjarneo/hackerman.nvim", colorscheme = "hackerman", bg = "dark" },
    ["matte-black"] = { plugin = "tahayvr/matteblack.nvim", colorscheme = "matteblack", bg = "dark" },
    ["lumon"] = { plugin = "omacom-io/lumon.nvim", colorscheme = "lumon", bg = "dark" },
    ["solitude"] = { plugin = "ficcdaf/ashen.nvim", colorscheme = "ashen", bg = "dark" },
    ["retro-82"] = { plugin = "OldJobobo/retro-82.nvim", colorscheme = "retro-82", bg = "dark" },
    ["miasma"] = { plugin = "xero/miasma.nvim", colorscheme = "miasma", bg = "dark" },
    -- Themes without a dedicated plugin: applied from colors.toml via fallback
    ["ethereal"] = { plugin = nil, colorscheme = nil, bg = "dark" },
    ["lupine"] = { plugin = nil, colorscheme = nil, bg = "dark" },
    ["last-horizon"] = { plugin = nil, colorscheme = nil, bg = "dark" },
    ["vantablack"] = { plugin = nil, colorscheme = nil, bg = "dark" },
    ["white"] = { plugin = nil, colorscheme = nil, bg = "light" },
    ["ristretto"] = { plugin = nil, colorscheme = nil, bg = "dark" },
}

local function apply_transparency()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

-- Apply colors from colors.toml when no dedicated colorscheme exists
local function apply_from_toml(theme_name)
    local path = os.getenv("HOME") .. "/dotfiles/themes/" .. theme_name .. "/colors.toml"
    local file = io.open(path, "r")
    if not file then
        return false
    end

    local colors = {}
    for line in file:lines() do
        local key, value = line:match('^(%w+)%s*=%s*"([^"]+)"')
        if key and value then
            colors[key] = value
        end
    end
    file:close()

    if not colors.background or not colors.foreground then
        return false
    end

    local bg = colors.background
    local fg = colors.foreground
    local accent = colors.accent or colors.blue or fg
    local muted = colors.muted or colors.dark_foreground or fg
    local selection = colors.selection or colors.lighter_background or bg
    local red = colors.red or "#ff0000"
    local green = colors.green or "#00ff00"
    local yellow = colors.yellow or "#ffff00"
    local blue = colors.blue or accent
    local cyan = colors.cyan or blue
    local magenta = colors.magenta or red

    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end
    vim.g.colors_name = "omarchy-" .. theme_name

    local function hi(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    hi("Normal", { fg = fg, bg = "NONE" })
    hi("NormalFloat", { fg = fg, bg = "NONE" })
    hi("Comment", { fg = muted, italic = true })
    hi("Constant", { fg = cyan })
    hi("String", { fg = green })
    hi("Character", { fg = green })
    hi("Number", { fg = yellow })
    hi("Boolean", { fg = yellow })
    hi("Identifier", { fg = blue })
    hi("Function", { fg = accent })
    hi("Statement", { fg = magenta })
    hi("Keyword", { fg = magenta })
    hi("PreProc", { fg = cyan })
    hi("Type", { fg = yellow })
    hi("Special", { fg = accent })
    hi("Underlined", { fg = blue, underline = true })
    hi("Error", { fg = red })
    hi("Todo", { fg = yellow, bold = true })
    hi("LineNr", { fg = muted })
    hi("CursorLineNr", { fg = accent, bold = true })
    hi("CursorLine", { bg = selection })
    hi("Visual", { bg = selection })
    hi("Search", { fg = bg, bg = yellow })
    hi("IncSearch", { fg = bg, bg = accent })
    hi("StatusLine", { fg = fg, bg = selection })
    hi("StatusLineNC", { fg = muted, bg = selection })
    hi("VertSplit", { fg = muted })
    hi("WinSeparator", { fg = muted })
    hi("Pmenu", { fg = fg, bg = selection })
    hi("PmenuSel", { fg = bg, bg = accent })
    hi("TabLine", { fg = muted, bg = selection })
    hi("TabLineSel", { fg = bg, bg = accent })
    hi("TabLineFill", { bg = selection })
    hi("DiagnosticError", { fg = red })
    hi("DiagnosticWarn", { fg = yellow })
    hi("DiagnosticInfo", { fg = blue })
    hi("DiagnosticHint", { fg = cyan })
    hi("DiffAdd", { fg = green })
    hi("DiffChange", { fg = yellow })
    hi("DiffDelete", { fg = red })
    hi("DiffText", { fg = blue })

    return true
end

local function apply_theme(theme_name)
    theme_name = theme_name or read_theme() or "gruvbox"
    local config = theme_configs[theme_name]

    vim.opt.termguicolors = true

    if config and config.colorscheme and config.plugin then
        vim.o.background = config.bg or "dark"

        -- Load plugin via lazy.nvim (match by repo URL — never guess short names)
        pcall(function()
            local lazy = require("lazy")
            for _, plug in ipairs(lazy.plugins()) do
                if plug[1] == config.plugin then
                    lazy.load({ plugins = { plug.name } })
                    break
                end
            end
        end)

        local ok = pcall(vim.cmd.colorscheme, config.colorscheme)
        if ok then
            apply_transparency()
            pcall(vim.cmd, "AirlineRefresh")
            return true
        end
    end

    -- Fallback: build colorscheme from colors.toml
    vim.o.background = (config and config.bg) or "dark"
    if apply_from_toml(theme_name) then
        apply_transparency()
        pcall(vim.cmd, "AirlineRefresh")
        return true
    end

    -- Last resort: toml-based default theme
    vim.o.background = "dark"
    if apply_from_toml("gruvbox") then
        apply_transparency()
        pcall(vim.cmd, "AirlineRefresh")
    end
    return false
end

-- Expose for theme switcher (nvr / :lua)
_G.OmarchyApplyTheme = apply_theme

local current_theme = read_theme() or "gruvbox"
local config = theme_configs[current_theme] or theme_configs["gruvbox"]

return {
    -- Dedicated theme plugins (name = lazy plugin id for live theme switching)
    { "ellisonleao/gruvbox.nvim", name = "gruvbox.nvim", lazy = true },
    { "ribru17/bamboo.nvim", lazy = true },
    { "folke/tokyonight.nvim", lazy = true },
    { "catppuccin/nvim", name = "catppuccin", lazy = true },
    { "rose-pine/neovim", name = "rose-pine", lazy = true },
    { "shaunsingh/nord.nvim", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = true },
    { "sainnhe/everforest", lazy = true },
    { "kepano/flexoki-neovim", lazy = true },
    { "xero/miasma.nvim", lazy = true },
    { "bjarneo/aether.nvim", lazy = true },
    { "bjarneo/hackerman.nvim", lazy = true, dependencies = { "bjarneo/aether.nvim" } },
    { "tahayvr/matteblack.nvim", lazy = true },
    { "omacom-io/lumon.nvim", lazy = true },
    { "ficcdaf/ashen.nvim", lazy = true },
    { "OldJobobo/retro-82.nvim", lazy = true },

    -- Apply theme on startup
    {
        "nvim-lua/plenary.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            apply_theme(current_theme)
        end,
    },
}
