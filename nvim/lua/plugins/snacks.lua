-- Snacks picker replaces Telescope (same keybinds)
return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			picker = {
				enabled = true,
				ui_select = true, -- replaces telescope-ui-select
				prompt = "  ",
				layout = {
					preset = "ivy", -- slides up from the bottom (instead of the centered "spotlight" box)
				},
			},
		},
		keys = {
			{ "<leader>fc", function() Snacks.picker.files() end, desc = "Find files" },
			{ "<leader>fh", function() Snacks.picker.help() end, desc = "Help tags" },
			{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
			{ "<leader>fv", function() Snacks.picker.grep() end, desc = "Live grep" },
		},
	},
}
