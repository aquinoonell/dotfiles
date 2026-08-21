return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>fc", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
			vim.keymap.set("n", "<leader>fv", builtin.live_grep, { desc = "Telescope live grep" })

			require("telescope").setup({
				defaults = {
					preview = {
						treesitter = {
							enable = false, -- disable ts previewer (incompatible with nvim-treesitter main branch)
						},
					},
					prompt_prefix = "  ",
					selection_caret = "  ",
					color_devicons = true,
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
						},
						width = 0.87,
						height = 0.80,
					},
					sorting_strategy = "ascending",
					borderchars = {
						"─",
						"│",
						"─",
						"│",
						"╭",
						"╮",
						"╯",
						"╰",
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")

			-- Apply gruvbox-matched colors to telescope highlights
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "gruvbox",
				callback = function()
					local bg_hard = "#1d2021"
					local bg1 = "#3c3836"
					local bg2 = "#504945"
					local fg = "#ebdbb2"
					local yellow = "#fabd2f"
					local blue = "#83a598"
					local gray = "#928374"

					vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = bg_hard, fg = fg })
					vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = bg_hard, fg = bg2 })
					vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = bg1, fg = fg })
					vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = bg1, fg = bg1 })
					vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = yellow, fg = bg_hard })
					vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = blue, fg = bg_hard })
					vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = bg_hard, fg = bg_hard })
					vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = bg2, fg = fg })
					vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { bg = bg2, fg = yellow })
					vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = yellow, bold = true })
					vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = yellow })
					vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = bg_hard })
					vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = bg_hard })
					vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = bg_hard, fg = bg2 })
					vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = bg_hard, fg = bg2 })
				end,
			})
			-- Fire immediately for current session
			vim.cmd("doautocmd ColorScheme gruvbox")
		end,
	},
}
