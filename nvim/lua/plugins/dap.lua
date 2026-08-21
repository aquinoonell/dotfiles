return {
    {
        "mfussenegger/nvim-dap",
        dependencies = { "nvim-neotest/nvim-nio" },
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            require("dapui").setup()

            local dap, dapui = require("dap"), require("dapui")
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
            -- Nvim DAP
            vim.keymap.set("n", "<Leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { desc = "Debugger step into" })
            vim.keymap.set("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { desc = "Debugger step over" })
            vim.keymap.set("n", "<Leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { desc = "Debugger step out" })
            vim.keymap.set("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<CR>", { desc = "Debugger continue" })
            vim.keymap.set(
                "n",
                "<Leader>db",
                "<cmd>lua require'dap'.toggle_breakpoint()<CR>",
                { desc = "Debugger toggle breakpoint" }
            )
            vim.keymap.set(
                "n",
                "<Leader>dd",
                "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
                { desc = "Debugger set conditional breakpoint" }
            )
            vim.keymap.set("n", "<Leader>de", "<cmd>lua require'dap'.terminate()<CR>", { desc = "Debugger reset" })
            vim.keymap.set("n", "<Leader>dr", "<cmd>lua require'dap'.run_last()<CR>", { desc = "Debugger run last" })

            -- rustaceanvim
            vim.keymap.set(
                "n",
                "<Leader>dt",
                "<cmd>lua vim.cmd('RustLsp testables')<CR>",
                { desc = "Debugger testables" }
            )
        end,
    },
}
