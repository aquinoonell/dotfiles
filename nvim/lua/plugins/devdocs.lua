return {
    "luckasRanarison/nvim-devdocs",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "MunifTanjim/nui.nvim",
    },
    cmd = { "DevdocsFetch", "DevdocsOpen", "DevdocsOpenFloat", "DevdocsInstall", "DevdocsUpdate" },
    opts = {
        wrap = true,
        previewer_cmd = nil,
        float_win = {
            relative = "editor",
            height = 30,
            width = 100,
            border = "rounded",
        },
        picker_cmd = true,
        picker_cmd_args = { "telescope" },
    },
    keys = {
        { "<leader>dd", "<cmd>DevdocsOpenFloat<cr>", desc = "DevDocs: open float" },
        { "<leader>df", "<cmd>DevdocsOpen<cr>",      desc = "DevDocs: open" },
    },
}
