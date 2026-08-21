-- Dynamic colorscheme loader for theme switcher
-- Reads ~/.nvim-colorscheme to determine which colorscheme to use

local M = {}

-- Read current colorscheme from file
local function read_colorscheme()
    local file = io.open(os.getenv("HOME") .. "/.nvim-colorscheme", "r")
    if file then
        local colorscheme = file:read("*l")
        file:close()
        return colorscheme
    end
    return nil
end

-- Read current theme name
local function read_theme()
    local file = io.open(os.getenv("HOME") .. "/.current-theme", "r")
    if file then
        local theme = file:read("*l")
        file:close()
        return theme
    end
    return nil
end

-- Map of theme names to their nvim plugin and colorscheme
local theme_configs = {
    ["osaka-jade"] = { plugin = "ribru17/bamboo.nvim", colorscheme = "bamboo" },
    ["gruvbox"] = { plugin = "ellisonleao/gruvbox.nvim", colorscheme = "gruvbox" },
    ["tokyo-night"] = { plugin = "folke/tokyonight.nvim", colorscheme = "tokyonight-night" },
    ["catppuccin"] = { plugin = "catppuccin/nvim", colorscheme = "catppuccin" },
    ["catppuccin-latte"] = { plugin = "catppuccin/nvim", colorscheme = "catppuccin-latte" },
    ["rose-pine"] = { plugin = "rose-pine/neovim", colorscheme = "rose-pine" },
    ["nord"] = { plugin = "shaunsingh/nord.nvim", colorscheme = "nord" },
    ["kanagawa"] = { plugin = "rebelot/kanagawa.nvim", colorscheme = "kanagawa" },
    ["everforest"] = { plugin = "sainnhe/everforest", colorscheme = "everforest" },
    ["matte-black"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
    ["vantablack"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
    ["hackerman"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
    ["ethereal"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
    ["miasma"] = { plugin = "xero/miasma.nvim", colorscheme = "miasma" },
    ["ristretto"] = { plugin = "ribru17/bamboo.nvim", colorscheme = "bamboo" },
    ["solitude"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
    ["lumon"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
    ["lupine"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
    ["last-horizon"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
    ["retro-82"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
    ["flexoki-light"] = { plugin = "kepano/flexoki-neovim", colorscheme = "flexoki-light" },
    ["white"] = { plugin = "Mofiqul/vscode.nvim", colorscheme = "vscode" },
}

-- Get current theme config
local current_theme = read_theme() or "gruvbox"
local config = theme_configs[current_theme] or theme_configs["gruvbox"]

return {
    -- Include all possible colorscheme plugins
    { "ellisonleao/gruvbox.nvim", lazy = true },
    { "ribru17/bamboo.nvim", lazy = true },
    { "folke/tokyonight.nvim", lazy = true },
    { "catppuccin/nvim", name = "catppuccin", lazy = true },
    { "rose-pine/neovim", name = "rose-pine", lazy = true },
    { "shaunsingh/nord.nvim", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = true },
    { "sainnhe/everforest", lazy = true },
    { "Mofiqul/vscode.nvim", lazy = true },
    { "xero/miasma.nvim", lazy = true },
    { "kepano/flexoki-neovim", lazy = true },
    
    -- Main colorscheme loader
    {
        "nvim-lua/plenary.nvim", -- Just a placeholder to run our setup
        priority = 1000,
        lazy = false,
        config = function()
            vim.o.background = "dark"
            vim.opt.termguicolors = true
            
            -- Try to load the colorscheme
            local ok, _ = pcall(function()
                vim.cmd.colorscheme(config.colorscheme)
            end)
            
            if not ok then
                -- Fallback to gruvbox
                vim.cmd.colorscheme("gruvbox")
            end
            
            -- Transparency for WezTerm
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        end,
    },
}
