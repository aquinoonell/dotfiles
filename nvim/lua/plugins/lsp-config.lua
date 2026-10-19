return {
    {
        "williamboman/mason.nvim",
        -- Don't pay mason startup cost until a buffer needs tooling
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "Mason", "MasonInstall", "MasonUpdate" },
        config = function()
            require("mason").setup()
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
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

            -- Apply blink.cmp capabilities to every server (nvim 0.11+)
            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            -- Filetype-gated: avoid spawning every language server in every project
            local function enable_for(ft, servers)
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = ft,
                    once = true,
                    callback = function()
                        vim.lsp.enable(servers)
                    end,
                })
            end

            enable_for({ "go", "gomod", "gowork" }, { "gopls" })
            enable_for({ "lua" }, { "lua_ls" })
            enable_for({ "typescript", "typescriptreact", "javascript", "javascriptreact" }, { "ts_ls" })
            enable_for({ "html" }, { "html" })
            enable_for({ "json", "jsonc" }, { "jsonls" })
            enable_for({ "yaml", "yml" }, { "yamlls" })
            enable_for({ "terraform", "tf" }, { "terraformls" })
            enable_for({ "sh", "bash", "zsh" }, { "bashls" })

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
                    -- Insert-mode signature uses <C-s> so it does not fight blink.cmp's <C-k>
                    vim.keymap.set("n", "K", function()
                        vim.lsp.buf.hover({ border = "rounded" })
                    end, { buffer = bufnr, desc = "Hover documentation" })

                    vim.keymap.set("i", "<C-s>", function()
                        vim.lsp.buf.signature_help({ border = "rounded" })
                    end, { buffer = bufnr, desc = "Signature help" })

                    vim.keymap.set("n", "<leader>k", function()
                        vim.lsp.buf.signature_help({ border = "rounded" })
                    end, { buffer = bufnr, desc = "Signature help" })

                    -- Format via none-ls / stylua on demand (<leader>gf); skip lua_ls on-save
                    -- to avoid fighting stylua.
                end,
            })
        end,
    },
}
