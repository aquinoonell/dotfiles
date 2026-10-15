return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                filesystem = {
                    follow_current_file = { enabled = true },
                    hijack_netrw_behavior = "open_default",
                },
            })
            -- Transparent sidebar so the wallpaper shows through like the editor
            local function transparent_tree()
                for _, g in ipairs({ "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer", "NeoTreeWinSeparator" }) do
                    local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
                    hl.bg = nil
                    hl.ctermbg = nil
                    vim.api.nvim_set_hl(0, g, hl)
                end
            end
            transparent_tree()
            vim.api.nvim_create_autocmd("ColorScheme", { callback = transparent_tree })

            vim.keymap.set("n", "<leader>n", ":Neotree filesystem reveal left<CR>", {
                desc = "Neo-tree: reveal file",
            })
        end,
    },
}
