local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 250

local wifi = sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	icon = { padding_left = 8, padding_right = 8 },
	label = { drawing = false },
})

-- Background around the item
local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
	wifi.name,
}, {
	background = { color = colors.bar.bg },
	popup = { align = "center", height = 22 },
})

local ssid = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		font = {
			style = settings.font.style_map["Bold"],
		},
		string = icons.wifi.router,
	},
	width = popup_width,
	align = "center",
	label = {
		font = {
			size = 15,
			style = settings.font.style_map["Bold"],
		},
		max_chars = 18,
		string = "????????????",
	},
	background = {
		height = 2,
		color = colors.grey,
		y_offset = -15,
	},
})

local hostname = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "Hostname:",
		width = popup_width / 2,
	},
	label = {
		max_chars = 20,
		string = "????????????",
		width = popup_width / 2,
		align = "right",
	},
})

local ip = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "IP:",
		width = popup_width / 2,
	},
	label = {
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

local mask = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "Subnet mask:",
		width = popup_width / 2,
	},
	label = {
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

local router = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "Router:",
		width = popup_width / 2,
	},
	label = {
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local ETHERNET_ICON = "􀤆" -- SF Symbol "network"
local WIFI_DEVICE = "en0"
local active_if = ""

-- Which interface carries the default route? Wi-Fi shows the wifi icon,
-- anything else (dock / USB ethernet) shows the ethernet icon.
local function update_connection()
	sbar.exec("route -n get default 2>/dev/null | awk '/interface:/{print $2}'", function(result)
		active_if = (type(result) == "string" and result:gsub("%s+", "")) or ""
		local icon, color
		if active_if == "" then
			icon, color = icons.wifi.disconnected, colors.semantic.error
		elseif active_if == WIFI_DEVICE then
			icon, color = icons.wifi.connected, colors.sora.steel
		else
			icon, color = ETHERNET_ICON, colors.sora.steel
		end
		wifi:set({ icon = { string = icon, color = color } })
	end)
end

wifi:set({ update_freq = 10 })
wifi:subscribe({ "wifi_change", "system_woke", "routine", "forced" }, update_connection)
update_connection()

local function hide_details()
	wifi_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
	local should_draw = wifi_bracket:query().popup.drawing == "off"
	if should_draw then
		wifi_bracket:set({ popup = { drawing = true } })
		sbar.exec("networksetup -getcomputername", function(result)
			hostname:set({ label = result })
		end)
		local iface = active_if ~= "" and active_if or WIFI_DEVICE
		sbar.exec("ipconfig getifaddr " .. iface, function(result)
			ip:set({ label = result })
		end)
		if iface == WIFI_DEVICE then
			sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
				ssid:set({ label = result })
			end)
		else
			ssid:set({ label = "Ethernet (" .. iface .. ")" })
		end
		sbar.exec("ipconfig getoption " .. iface .. " subnet_mask", function(result)
			mask:set({ label = result })
		end)
		sbar.exec("route -n get default 2>/dev/null | awk '/gateway:/{print $2}'", function(result)
			router:set({ label = result })
		end)
	else
		hide_details()
	end
end

wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)

local function copy_label_to_clipboard(env)
	local label = sbar.query(env.NAME).label.value
	sbar.exec('echo "' .. label .. '" | pbcopy')
	sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
	sbar.delay(1, function()
		sbar.set(env.NAME, { label = { string = label, align = "right" } })
	end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
