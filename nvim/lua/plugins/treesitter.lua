return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
        -- main branch dropped ensure_installed; this runs on :Lazy sync / :TSUpdate,
        -- not on every startup, so it self-heals when you add a language here.
        local ensure_installed = { "rust", "lua", "vim", "vimdoc", "bash", "markdown", "markdown_inline" }
        require("nvim-treesitter").install(ensure_installed)
        vim.cmd("TSUpdate")
    end,
    config = function()
        -- New main branch: setup() only takes install_dir, no highlight/indent options
        require("nvim-treesitter").setup()

        -- Patch ft_to_lang for Telescope compatibility (removed in main branch rewrite)
        local ok, parsers = pcall(require, "nvim-treesitter.parsers")
        if ok and not parsers.ft_to_lang then
            parsers.ft_to_lang = function(ft)
                return vim.treesitter.language.get_lang(ft) or ft
            end
        end

        -- Enable treesitter highlighting for all filetypes
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "*",
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end,
}
