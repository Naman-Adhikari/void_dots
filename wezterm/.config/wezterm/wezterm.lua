-- ============================================================
-- WEZTERM // MONOCHROME CONFIGURATION
-- ============================================================

local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- ============================================================
-- PERFORMANCE
-- ============================================================

config.max_fps = 240
config.animation_fps = 240

-- ============================================================
-- WINDOW
-- ============================================================

config.font_size = 14
config.window_decorations = "RESIZE"
config.enable_scroll_bar = false
config.window_close_confirmation = "NeverPrompt"

-- ============================================================
-- MONOCHROME COLOR PALETTE
-- ============================================================

local palette = {
	bg = "#090909",
	panel = "#111111",
	active = "#202020",
	hover = "#292929",
	border = "#444444",

	white = "#eeeeee",
	text = "#d0d0d0",
	gray = "#999999",
	muted = "#555555",

	black = "#090909",
}

config.colors = {
	foreground = palette.text,
	background = palette.bg,

	cursor_bg = palette.white,
	cursor_fg = palette.black,
	cursor_border = palette.white,

	selection_bg = "#444444",
	selection_fg = palette.white,

	-- ANSI colors
	ansi = {
		"#090909",
		"#777777",
		"#999999",
		"#aaaaaa",
		"#888888",
		"#999999",
		"#bbbbbb",
		"#d0d0d0",
	},

	-- Bright ANSI colors
	brights = {
		"#555555",
		"#999999",
		"#bbbbbb",
		"#cccccc",
		"#aaaaaa",
		"#bbbbbb",
		"#dddddd",
		"#eeeeee",
	},

	-- Split pane borders
	split = palette.border,

	-- Tab bar
	tab_bar = {
		background = palette.bg,

		active_tab = {
			bg_color = palette.active,
			fg_color = palette.white,
			intensity = "Bold",
		},

		inactive_tab = {
			bg_color = palette.panel,
			fg_color = palette.gray,
		},

		inactive_tab_hover = {
			bg_color = palette.hover,
			fg_color = palette.white,
		},

		new_tab = {
			bg_color = palette.bg,
			fg_color = palette.muted,
		},

		new_tab_hover = {
			bg_color = palette.active,
			fg_color = palette.white,
		},
	},
}

-- ============================================================
-- SHORTCUTS
-- ============================================================

config.leader = {
	key = "Space",
	mods = "CTRL",
	timeout_milliseconds = 2000,
}

config.keys = {
	-- Tabs
	{
		mods = "LEADER",
		key = "c",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		mods = "LEADER",
		key = "d",
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
	},

	-- Panes
	{
		mods = "LEADER",
		key = "x",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		mods = "LEADER",
		key = "\\",
		action = wezterm.action.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		mods = "LEADER",
		key = "-",
		action = wezterm.action.SplitVertical({
			domain = "CurrentPaneDomain",
		}),
	},

	-- Tab navigation
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

	-- Pane navigation
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

	-- Resize panes
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

-- Leader + 0-9 selects tabs
for i = 0, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i),
	})
end

-- ============================================================
-- TAB BAR
-- ============================================================

config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true
config.tab_max_width = 28

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

wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
	local index = string.format("%02d", tab.tab_index)
	local title = tab_title(tab)

	local marker = tab.is_active and "◈" or "◇"

	title = wezterm.truncate_right(title, math.max(max_width - 10, 1))

	local bg = tab.is_active and palette.active or (hover and palette.hover or palette.panel)

	local fg = tab.is_active and palette.white or (hover and palette.white or palette.gray)

	local marker_color = tab.is_active and palette.white or palette.muted

	return {
		{ Background = { Color = bg } },

		{ Foreground = { Color = palette.border } },
		{ Text = "  " },

		{ Foreground = { Color = marker_color } },
		{ Text = marker .. " " },

		{ Foreground = { Color = fg } },
		{ Text = index .. "  " .. title },

		{ Foreground = { Color = palette.border } },
		{ Text = "  │  " },
	}
end)

-- ============================================================
-- STATUS HUD
-- ============================================================

wezterm.on("update-status", function(window, pane)
	-- LEFT: Leader indicator
	if window:leader_is_active() then
		window:set_left_status(wezterm.format({
			{ Background = { Color = palette.white } },
			{ Foreground = { Color = palette.black } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " ◈09 " },

			{ Background = { Color = "#252525" } },
			{ Foreground = { Color = palette.white } },
			{ Text = " CMD " },

			{ Background = { Color = palette.white } },
			{ Foreground = { Color = palette.black } },
			{ Text = " ▰ " },

			{ Background = { Color = palette.bg } },
		}))
	else
		window:set_left_status("")
	end

	-- RIGHT: Git branch
	local user_vars = pane:get_user_vars()
	local branch = user_vars.git_branch or ""

	if branch ~= "" then
		window:set_right_status(wezterm.format({
			{ Background = { Color = palette.bg } },
			{ Foreground = { Color = palette.muted } },
			{ Text = " GIT " },

			{ Background = { Color = palette.active } },
			{ Foreground = { Color = palette.white } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " 󰘬 " .. branch .. " " },

			{ Background = { Color = palette.bg } },
			{ Text = " " },
		}))
	else
		window:set_right_status("")
	end
end)

return config
