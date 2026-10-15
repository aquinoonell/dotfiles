return {
    {
        "mrcjkb/rustaceanvim",
        version = "^6",
        lazy = false,
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

                return { dap = dap }
            end
        end,
    },
}
