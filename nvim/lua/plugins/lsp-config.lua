return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "saghen/blink.cmp",
            {
                "folke/lazydev.nvim",
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
        },
        config = function()
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            vim.lsp.enable({
                "gopls",
                "lua_ls",
                "ts_ls",
                "html",
                "jsonls",
                "yamlls",
                "terraformls",
                "bashls",
            })

            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "x",
                        [vim.diagnostic.severity.WARN] = "!",
                        [vim.diagnostic.severity.INFO] = "i",
                        [vim.diagnostic.severity.HINT] = "H",
                    },
                },
            })

            -- Rounded borders for hover/signature float windows
            vim.o.winborder = "rounded"

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local c = vim.lsp.get_client_by_id(args.data.client_id)
                    if not c then
                        return
                    end

                    local bufnr = args.buf

                    -- Hover & signature help
                    vim.keymap.set("n", "K", function()
                        vim.lsp.buf.hover({ border = "rounded" })
                    end, { buffer = bufnr, desc = "Hover documentation" })

                    vim.keymap.set("i", "<C-k>", function()
                        vim.lsp.buf.signature_help({ border = "rounded" })
                    end, { buffer = bufnr, desc = "Signature help" })

                    vim.keymap.set("n", "<leader>k", function()
                        vim.lsp.buf.signature_help({ border = "rounded" })
                    end, { buffer = bufnr, desc = "Signature help" })

                    if vim.bo.filetype == "lua" then
                        -- Format the current buffer on save
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = args.buf,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = args.buf, id = c.id })
                            end,
                        })
                    end
                end,
            })
        end,
    },
}
