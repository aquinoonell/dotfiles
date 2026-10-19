return {
    "lervag/vimtex",
    ft = { "tex", "latex", "plaintex" },
    -- Must set globals before plugin loads (vimtex reads them on init)
    init = function()
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_view_forward_search_on_start = true
        vim.g.vimtex_compiler_latexmk = {
            options = {
                "-verbose",
                "-file-line-error",
                "-synctex=1",
                "-interaction=nonstopmode",
            },
        }
        -- Quickcfix quiet; keep toc/errors useful
        vim.g.vimtex_quickfix_mode = 0
    end,
    config = function()
        -- Forward search: \\lv (localleader = \\)
        -- Compile: \\ll   Stop: \\lk   TOC: \\lt
        vim.keymap.set("n", "<leader>zv", "<cmd>VimtexView<cr>", { desc = "Zathura forward search", silent = true })
        vim.keymap.set("n", "<leader>zc", "<cmd>VimtexCompile<cr>", { desc = "LaTeX compile", silent = true })
    end,
}
