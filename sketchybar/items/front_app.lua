local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", "front_app", {
	display = "active",
	icon = { drawing = false },
	label = {
		font = {
			style = settings.font.style_map["Bold"],
			size = 12.0,
		},
		color = colors.white,
		padding_left = 10,
		padding_right = 10,
	},
	-- own pill so the name stays readable over any wallpaper/theme
	background = {
		drawing = true,
		color = colors.bar.bg,
		border_width = 2,
		border_color = colors.bg2,
	},
	updates = true,
})

front_app:subscribe("front_app_switched", function(env)
	front_app:set({ label = { string = env.INFO } })
end)
