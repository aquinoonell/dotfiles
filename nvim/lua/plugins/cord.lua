-- ~/.config/nvim/lua/plugins/cord.lua

return {
    "vyfor/cord.nvim",
    build = "cargo build --release",
    event = "VeryLazy",
    opts = {
        usercmds = true,
        log_level = "off",
        timer = {
            interval = 1500,
            reset_on_idle = false,
            reset_on_change = false,
        },
        editor = {
            image = nil,
            client = "neovim",
            tooltip = "Neovim",
        },
        display = {
            show_time = true,    -- Show elapsed time
            show_repository = false, -- Hide repository button
            show_cursor_position = false, -- Hide cursor position
            swap_fields = false,
            swap_icons = false,
            workspace_blacklist = {},
        },
        lsp = {
            show_problem_count = false,
            severity = 1,
            scope = "workspace",
        },
        idle = {
            enable = true,
            show_status = true,
            timeout = 300000, -- 5 minutes
            disable_on_focus = false,
            smart_idle = false,
            text = "Idle",
            tooltip = "💤",
        },
        text = {
            viewing = "Editing", -- Generic text, no file info
            editing = "Editing",
            file_browser = "Browsing",
            plugin_manager = "Configuring",
            lsp_manager = "Configuring",
            vcs = "Working",
            workspace = "", -- Hide workspace name
        },
        buttons = {}, -- No buttons at all
        assets = nil,
    },
}
