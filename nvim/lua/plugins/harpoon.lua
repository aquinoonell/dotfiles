return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        vim.keymap.set("n", "<leader>hm", function()
            harpoon:list():add()
        end, { desc = "Mark file with harpoon" })

        vim.keymap.set("n", "<leader>hn", function()
            harpoon:list():next()
        end, { desc = "Go to next harpoon mark" })

        vim.keymap.set("n", "<leader>hp", function()
            harpoon:list():prev()
        end, { desc = "Go to previous harpoon mark" })

        vim.keymap.set("n", "<leader>ha", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Show harpoon marks" })
    end,
}
