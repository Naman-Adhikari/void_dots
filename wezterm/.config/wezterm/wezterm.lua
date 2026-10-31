-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- max fps
config.max_fps = 240
config.animation_fps = 240

--[[
============================
Custom Configuration
============================
]]
--

-- Rounded or Square Style Tabs

-- change to square if you don't like rounded tab style
local tab_style = "rounded"

-- leader active indicator prefix
local leader_prefix = utf8.char(0x1f30a) -- ocean wave

--[[
============================
Font
============================
]]
--

config.font_size = 14

config.window_decorations = "RESIZE"

config.enable_scroll_bar = false

--[[
============================
Colors
============================
]]
--

--local color_scheme = "Batman"
--config.color_scheme = color_scheme

-- color_scheme not sufficient in providing available colors
-- local colors = wezterm.color.get_builtin_schemes()[color_scheme]

-- Monochrome color scheme
local scheme_colors = {
	monochrome = {
		dark = {
			rosewater = "#eeeeee",
			flamingo = "#dddddd",
			pink = "#cccccc",
			mauve = "#bbbbbb",
			red = "#aaaaaa",
			maroon = "#999999",
			peach = "#888888",
			yellow = "#eeeeee",
			green = "#cccccc",
			teal = "#aaaaaa",
			sky = "#dddddd",
			sapphire = "#bbbbbb",
			blue = "#eeeeee",
			lavender = "#f2f2f2",
			text = "#e0e0e0",
			crust = "#090909",
		},
	},
}

local mono = scheme_colors.monochrome.dark

local colors = {
	border = mono.lavender,

	tab_bar_active_tab_fg = mono.text,
	tab_bar_active_tab_bg = mono.crust,
	tab_bar_text = mono.peach,

	arrow_foreground_leader = mono.text,
	arrow_background_leader = mono.crust,
}

--[[
============================
Border
============================
]]
--

--config.window_frame = {
--border_left_width = "0.4cell",
--border_right_width = "0.4cell",
--border_bottom_height = "0.15cell",
--border_top_height = "0.15cell",
--border_left_color = colors.border,
--border_right_color = colors.border,
--border_bottom_color = colors.border,
--border_top_color = colors.border,
--}

--[[
============================
Shortcuts
============================
]]
--

-- shortcut_configuration
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
	{
		mods = "LEADER",
		key = "c",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		mods = "LEADER",
		key = "x",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},

	{
		mods = "LEADER",
		key = "d",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},

	{
		mods = "LEADER",
		key = "b",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		mods = "LEADER",
		key = "n",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		mods = "LEADER",
		key = "\\",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "-",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "h",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		mods = "LEADER",
		key = "j",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		mods = "LEADER",
		key = "k",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		mods = "LEADER",
		key = "l",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		mods = "LEADER",
		key = "LeftArrow",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		mods = "LEADER",
		key = "RightArrow",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		mods = "LEADER",
		key = "DownArrow",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		mods = "LEADER",
		key = "UpArrow",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
}

for i = 0, 9 do
	-- leader + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i),
	})
end

--[[
============================
SECTION 09 // CYBERNETIC UI
============================
]]

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true
config.tab_max_width = 28

local section9 = {
	bg = "#090909",
	panel = "#111111",
	active = "#202020",
	border = "#444444",
	white = "#eeeeee",
	text = "#999999",
	muted = "#555555",
}

config.colors = config.colors or {}
config.colors.tab_bar = {
	background = section9.bg,

	active_tab = {
		bg_color = section9.active,
		fg_color = section9.white,
		intensity = "Bold",
	},

	inactive_tab = {
		bg_color = section9.panel,
		fg_color = section9.text,
	},

	inactive_tab_hover = {
		bg_color = "#292929",
		fg_color = section9.white,
	},

	new_tab = {
		bg_color = section9.bg,
		fg_color = section9.muted,
	},

	new_tab_hover = {
		bg_color = section9.active,
		fg_color = section9.white,
	},
}

local function tab_title(tab_info)
	local title = tab_info.tab_title

	if title and #title > 0 then
		return title
	end

	title = tab_info.active_pane.title

	if title == "~" then
		return "SHELL"
	end

	return title ~= "" and title or "TERMINAL"
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local index = string.format("%02d", tab.tab_index)
	local title = tab_title(tab)

	local marker = tab.is_active and "◈" or "◇"

	local available = math.max(max_width - 10, 1)
	title = wezterm.truncate_right(title, available)

	local bg = tab.is_active and section9.active or (hover and "#292929" or section9.panel)

	local fg = tab.is_active and section9.white or (hover and section9.white or section9.text)

	local marker_color = tab.is_active and section9.white or section9.muted

	return {
		{ Background = { Color = bg } },

		{ Foreground = { Color = section9.border } },
		{ Text = "  " },

		{ Foreground = { Color = marker_color } },
		{ Text = marker .. " " },

		{ Foreground = { Color = fg } },
		{ Text = index .. "  " .. title },

		{ Foreground = { Color = section9.border } },
		{ Text = "  │  " },
	}
end)

--[[
============================
SECTION 09 // COMPACT HUD
============================
]]

wezterm.on("update-status", function(window, _)
	if window:leader_is_active() then
		window:set_left_status(wezterm.format({
			{ Background = { Color = "#eeeeee" } },
			{ Foreground = { Color = "#090909" } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " ◈09 " },

			{ Background = { Color = "#252525" } },
			{ Foreground = { Color = "#eeeeee" } },
			{ Text = " CMD " },

			{ Background = { Color = "#eeeeee" } },
			{ Foreground = { Color = "#090909" } },
			{ Text = " ▰ " },

			{ Background = { Color = "#090909" } },
		}))
	else
		window:set_left_status("")
	end

	window:set_left_status(wezterm.format({
		{ Background = { Color = colors.arrow_foreground_leader } },
		{ Text = prefix },
		arrow_foreground,
		arrow_background,
		{ Text = solid_left_arrow },
	}))
end)

-- and finally, return the configuration to wezterm
return config
