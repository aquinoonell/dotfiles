-- Debugger: nothing loads until the first <leader>d* key (or :Dap* / a Rust debug run).
local function dap(fn, ...)
    local args = { ... }
    return function()
        local d = require("dap")
        d[fn](unpack(args))
    end
end

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "rcarriga/nvim-dap-ui",
        },
        keys = {
            { "<Leader>dl", dap("step_into"), desc = "Debugger step into" },
            { "<Leader>dj", dap("step_over"), desc = "Debugger step over" },
            { "<Leader>dk", dap("step_out"), desc = "Debugger step out" },
            { "<Leader>dc", dap("continue"), desc = "Debugger continue" },
            { "<Leader>db", dap("toggle_breakpoint"), desc = "Debugger toggle breakpoint" },
            -- <leader>dd is DevDocs; use dC for conditional breakpoint
            {
                "<Leader>dC",
                function()
                    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
                end,
                desc = "Debugger set conditional breakpoint",
            },
            { "<Leader>de", dap("terminate"), desc = "Debugger reset" },
            { "<Leader>dr", dap("run_last"), desc = "Debugger run last" },
            { "<Leader>dt", "<cmd>RustLsp testables<CR>", desc = "Debugger testables" },
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup()

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
        end,
    },
}
