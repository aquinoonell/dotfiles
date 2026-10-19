-- Aejkatappaja's spaces item, driven by Rift workspaces instead of native
-- macOS spaces (same look, same double-border highlight, same app icons).
local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local RIFT = "/opt/homebrew/bin/rift-cli"
local JQ = "/opt/homebrew/bin/jq"
local WORKSPACES = 9
local ALWAYS_SHOWN = 0 -- spaces only show when they have windows or are focused

for _, ev in ipairs({
	"rift_workspace_changed",
	"rift_windows_changed",
	"rift_focused_window_changed",
	"rift_layout_changed",
	"rift_stacks_changed",
}) do
	sbar.add("event", ev)
end

local spaces = {}
local brackets = {}

for i = 1, WORKSPACES, 1 do
	local space = sbar.add("item", "space." .. i, {
		icon = {
			font = { family = "Liga SFMono Nerd Font", style = "Bold", size = 13.0 },
			string = i,
			padding_left = 10,
			padding_right = 10,
			color = colors.white,
			highlight_color = colors.orange,
		},
		label = {
			drawing = false,
		},
		padding_right = 1,
		padding_left = 1,
		background = {
			color = colors.bar.bg,
			border_width = 2,
			height = 22,
			border_color = colors.black,
		},
		drawing = i <= ALWAYS_SHOWN,
	})

	spaces[i] = space

	-- Single item bracket for space items to achieve double border on highlight
	brackets[i] = sbar.add("bracket", { space.name }, {
		background = {
			color = colors.transparent,
			border_color = colors.bg2,
			height = 24,
			border_width = 2,
		},
	})

	-- Padding space
	sbar.add("item", "space.padding." .. i, {
		script = "",
		width = settings.group_paddings,
		drawing = i <= ALWAYS_SHOWN,
	})

	-- Rift workspace indexes are 0-based
	space:subscribe("mouse.clicked", function(_)
		sbar.exec(RIFT .. " execute workspace switch " .. (i - 1))
	end)
end

local rift_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

local function icon_line_for(apps)
	local icon_line = ""
	local no_app = true
	for app in apps:gmatch("[^,]+") do
		no_app = false
		local lookup = app_icons[app]
		local icon = ((lookup == nil) and app_icons["default"] or lookup)
		icon_line = icon_line .. " " .. icon
	end
	if no_app then
		icon_line = " —"
	end
	return icon_line
end

local function refresh()
	-- index | active | comma separated app names
	local cmd = RIFT
		.. " query workspaces 2>/dev/null | "
		.. JQ
		.. " -r '.[] | \"\\(.index)|\\(.is_active)|\\([.windows[].app_name] | unique | join(\",\"))\"'"
	sbar.exec(cmd, function(result)
		if type(result) ~= "string" then
			return
		end
		for line in result:gmatch("[^\r\n]+") do
			local idx, active, apps = line:match("^(%d+)|(%a+)|(.*)$")
			if idx then
				local i = tonumber(idx) + 1
				local space = spaces[i]
				if space then
					local selected = active == "true"
					local occupied = apps ~= ""
					local visible = selected or occupied or i <= ALWAYS_SHOWN
					space:set({
						drawing = visible,
						icon = { highlight = selected },
												background = { border_color = selected and colors.highlight or colors.bar.bg },
					})
					brackets[i]:set({
						drawing = visible,
						background = { border_color = selected and colors.grey or colors.bg2 },
					})
					sbar.set("space.padding." .. i, { drawing = visible })
				end
			end
		end
	end)
end

rift_observer:subscribe({
	"rift_workspace_changed",
	"rift_windows_changed",
	"rift_focused_window_changed",
	"rift_layout_changed",
	"rift_stacks_changed",
	"forced",
	"system_woke",
}, refresh)

refresh()
-- A reload (theme switch) can race with Rift's startup state; re-sync shortly after
sbar.delay(1, refresh)
sbar.delay(3, refresh)
