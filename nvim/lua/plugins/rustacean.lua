return {
    {
        "mrcjkb/rustaceanvim",
        version = "^6",
        lazy = true,
        ft = "rust",
        -- Function form is evaluated when rustaceanvim starts (plugin already on rtp)
        init = function()
            vim.g.rustaceanvim = function()
                local mason_path = vim.fn.stdpath("data") .. "/mason"
                local extension_path = mason_path .. "/packages/codelldb/extension/"
                local codelldb_path = extension_path .. "adapter/codelldb"
                local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"

                local dap = {}
                if vim.fn.executable(codelldb_path) == 1 then
                    local cfg = require("rustaceanvim.config")
                    dap.adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
                end

                return {
                    dap = dap,
                    server = {
                        default_settings = {
                            ["rust-analyzer"] = {
                                -- Cap analysis cache; big crates otherwise pin 1GB+ RSS
                                lru = { capacity = 128 },
                                files = {
                                    watcher = "server",
                                    excludeDirs = {
                                        ".git",
                                        "target",
                                        "node_modules",
                                    },
                                },
                                cargo = {
                                    -- Skip building every target by default
                                    allTargets = false,
                                },
                                check = {
                                    command = "check",
                                },
                                procMacro = {
                                    enable = true,
                                },
                            },
                        },
                    },
                }
            end
        end,
    },
}
