return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    cmd = {
        "Obsidian",
    },
    ft = "markdown",

    keys = {
        {
            "<leader>on",
            function()
                local vault = "/Users/onell/Documents/Obsidian Vault"
                local dir = vim.fn.expand("%:p:h")
                local rel = dir:gsub(vim.pesc(vault) .. "/?", "")
                vim.ui.input({ prompt = "New note title: " }, function(title)
                    if title and title ~= "" then
                        local path = rel ~= "" and (rel .. "/" .. title) or title
                        vim.cmd("Obsidian new " .. path)
                    end
                end)
            end,
            desc = "New Obsidian note in current folder",
        },
    },

    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },

    opts = {
        workspaces = {
            {
                name = "main",
                path = "/Users/onell/Documents/Obsidian Vault",
            },
        },

        note_id_func = function(title)
            return title and title:gsub(" ", "-") or tostring(os.time())
        end,

        legacy_commands = false,

        notes_subdir = "Projects",

        daily_notes = {
            folder = "Daily",
            date_format = "%Y-%m-%d",
        },
    },
}
