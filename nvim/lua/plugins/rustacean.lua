return {
    {
        "mrcjkb/rustaceanvim",
        version = "^6",
        lazy = false,
        ft = "rust",
        config = function()
            local mason_path = vim.fn.stdpath("data") .. "/mason"
            local extension_path = mason_path .. "/packages/codelldb/extension/"
            local codelldb_path = extension_path .. "adapter/codelldb"
            local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
            local cfg = require("rustaceanvim.config")

            vim.g.rustaceanvim = {
                dap = {
                    adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
                },
            }
        end,
    },
}
