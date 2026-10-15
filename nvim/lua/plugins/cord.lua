-- Discord Rich Presence (cord.nvim current config schema)
return {
    "vyfor/cord.nvim",
    build = ":Cord update",
    event = "VeryLazy",
    opts = {
        log_level = vim.log.levels.OFF,
        editor = {
            client = "neovim",
            tooltip = "Neovim",
        },
        display = {
            theme = "default",
            flavor = "dark",
            view = "full",
            swap_fields = false,
            swap_icons = false,
        },
        timestamp = {
            enabled = true,
            reset_on_idle = false,
            reset_on_change = false,
        },
        idle = {
            enabled = true,
            timeout = 300000,
            show_status = true,
            ignore_focus = false,
            smart_idle = false,
            details = "Idle",
            tooltip = "💤",
        },
        -- Keep presence generic (no file/workspace leakage)
        text = {
            viewing = "Editing",
            editing = "Editing",
            file_browser = "Browsing",
            plugin_manager = "Configuring",
            lsp = "Configuring",
            vcs = "Working",
            workspace = "",
        },
        buttons = nil,
        assets = nil,
    },
}
