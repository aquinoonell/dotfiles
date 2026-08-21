return {
    "morhetz/gruvbox",
    priority = 1000,
    lazy = false,
    config = function()
        vim.o.background = "dark"
        vim.g.gruvbox_contrast_dark = "medium"
        vim.g.gruvbox_italic = 1
        vim.g.gruvbox_bold = 1
        vim.g.gruvbox_sign_column = "bg0"
        vim.g.gruvbox_invert_selection = 0
        vim.cmd.colorscheme("gruvbox")

        -- Slight transparency - lets WezTerm's window_background_opacity show through
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
}
