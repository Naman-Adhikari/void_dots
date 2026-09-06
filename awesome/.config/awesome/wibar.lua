local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

---------------------------------------------------------------------
-- COLORS
---------------------------------------------------------------------

local bar_bg = "#090909"
local module_bg = "#111111"
local module_bg2 = "#151515"

local fg = "#888888"
local fg_dim = "#555555"
local fg_bright = "#eeeeee"

local active_bg = "#e8e8e8"
local active_fg = "#090909"

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------

local function margin(widget, left, right, top, bottom)
	return wibox.container.margin(widget, left or 0, right or 0, top or 0, bottom or 0)
end

local function module(widget, background)
	return wibox.container.background(widget, background or module_bg, gears.shape.rounded_rect)
end

---------------------------------------------------------------------
-- TAGLIST BUTTONS
---------------------------------------------------------------------

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),

	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),

	awful.button({}, 3, awful.tag.viewtoggle),

	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),

	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),

	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

---------------------------------------------------------------------
-- TASKLIST BUTTONS
---------------------------------------------------------------------

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),

	awful.button({}, 3, function()
		awful.menu.client_list({
			theme = {
				width = 250,
			},
		})
	end),

	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),

	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

---------------------------------------------------------------------
-- BATTERY
---------------------------------------------------------------------

local battery = wibox.widget.textbox()

battery.font = "JetBrainsMono Nerd Font 9"
battery.align = "center"
battery.valign = "center"
battery.forced_width = 72

local function update_battery()
	awful.spawn.easy_async_with_shell("cat /sys/class/power_supply/BAT0/capacity 2>/dev/null", function(stdout)
		local percent = tonumber(stdout:match("%d+"))

		if percent then
			battery.text = string.format("BAT %3d%%", percent)
		else
			battery.text = "BAT ---%"
		end
	end)
end

update_battery()

gears.timer({
	timeout = 30,
	autostart = true,
	callback = update_battery,
})
---------------------------------------------------------------------
-- SETUP FUNCTION
---------------------------------------------------------------------

local function setup(s)
	-----------------------------------------------------------------
	-- TAGLIST
	-----------------------------------------------------------------

	local taglist = awful.widget.taglist({
		screen = s,

		filter = awful.widget.taglist.filter.all,

		buttons = taglist_buttons,

		layout = {
			spacing = 3,
			layout = wibox.layout.fixed.horizontal,
		},

		widget_template = {
			{
				{
					id = "text_role",

					align = "center",
					valign = "center",

					font = "JetBrainsMono Nerd Font Bold 9",

					widget = wibox.widget.textbox,
				},

				left = 9,
				right = 9,
				top = 4,
				bottom = 4,

				widget = wibox.container.margin,
			},

			id = "background_role",

			bg = module_bg,
			fg = fg_dim,

			shape = gears.shape.rounded_rect,

			widget = wibox.container.background,
		},
	})

	-----------------------------------------------------------------
	-- TASKLIST
	-----------------------------------------------------------------

	local tasklist = awful.widget.tasklist({
		screen = s,

		filter = awful.widget.tasklist.filter.currenttags,

		buttons = tasklist_buttons,

		layout = {
			spacing = 4,
			layout = wibox.layout.flex.horizontal,
		},

		widget_template = {
			{
				{
					id = "text_role",

					align = "center",
					valign = "center",

					font = "JetBrainsMono Nerd Font 8",

					widget = wibox.widget.textbox,
				},

				left = 10,
				right = 10,
				top = 4,
				bottom = 4,

				widget = wibox.container.margin,
			},

			id = "background_role",

			bg = module_bg,
			fg = fg,

			shape = gears.shape.rounded_rect,

			widget = wibox.container.background,
		},
	})

	-----------------------------------------------------------------
	-- PROMPT
	-----------------------------------------------------------------

	local promptbox = awful.widget.prompt()

	-----------------------------------------------------------------
	-- POWER PROFILE
	-----------------------------------------------------------------

	local power_profile = wibox.widget.textbox()

	power_profile.font = "JetBrainsMono Nerd Font 9"
	power_profile.align = "center"
	power_profile.valign = "center"
	power_profile.forced_width = 32

	---------------------------------------------------------------
	-- UPDATE ICON FROM CURRENT GOVERNOR
	---------------------------------------------------------------

	local function update_power_profile()
		awful.spawn.easy_async_with_shell(
			"cpupower frequency-info 2>/dev/null | grep -oP 'governor \"\\K[^\"]+' | head -1",
			function(stdout)
				local governor = stdout:gsub("%s+", "")

				if governor == "performance" then
					power_profile.text = "󰓅"
				elseif governor == "powersave" then
					power_profile.text = "󰾆"
				else
					power_profile.text = "󰚥"
				end
			end
		)
	end

	---------------------------------------------------------------
	-- SET GOVERNOR
	---------------------------------------------------------------

	local function set_power_profile(governor)
		awful.spawn.easy_async_with_shell(
			"sudo -n /usr/sbin/cpupower frequency-set -g " .. governor,
			function(stdout, stderr, reason, exit_code)
				if exit_code == 0 then
					update_power_profile()

					local name = governor == "performance" and "Performance" or "Power Save"

					local icon = governor == "performance" and "󰓅" or "󰾆"

					awful.spawn.with_shell(
						"notify-send "
							.. string.format("-a 'Power Profile' -i power-profile 'Power Profile' '%s %s'", icon, name)
					)
				else
					power_profile.text = "󰚥"

					awful.spawn.with_shell("notify-send -a 'Power Profile' 'Power Profile' 'Failed to switch profile'")

					print("cpupower error: " .. stderr)
				end
			end
		)
	end
	---------------------------------------------------------------
	-- INITIAL STATE
	---------------------------------------------------------------

	update_power_profile()

	---------------------------------------------------------------
	-- MENU
	---------------------------------------------------------------

	local power_menu = awful.menu({
		theme = {
			width = 160,
			height = 30,

			font = "JetBrainsMono Nerd Font 9",

			bg_normal = module_bg,
			fg_normal = fg,

			bg_focus = active_bg,
			fg_focus = active_fg,

			border_width = 0,
		},

		items = {
			{
				"Performance",
				function()
					set_power_profile("performance")
				end,
			},

			{
				"Power Save",
				function()
					set_power_profile("powersave")
				end,
			},
		},
	})

	---------------------------------------------------------------
	-- CLICK BUTTON
	---------------------------------------------------------------

	power_profile:buttons(gears.table.join(awful.button({}, 1, function()
		power_menu:toggle()
	end)))

	local power_module = module(margin(power_profile, 7, 7, 3, 3), module_bg)

	-----------------------------------------------------------------
	-- CLOCK
	-----------------------------------------------------------------

	local clock = wibox.widget.textclock("%H:%M")

	clock.font = "JetBrainsMono Nerd Font Bold 13"
	clock.fg = fg_bright
	clock.align = "center"
	clock.valign = "center"

	clock.forced_width = 58

	local clock_module = module(margin(clock, 9, 9, 4, 4), module_bg2)

	-----------------------------------------------------------------
	-- DATE
	--
	-- Separate from the clock so it doesn't get squeezed underneath
	-- the time.
	-----------------------------------------------------------------

	local date = wibox.widget.textclock("%a  %d %b")

	date.font = "JetBrainsMono Nerd Font 9"
	date.fg = fg_bright
	date.align = "center"
	date.valign = "center"

	date.forced_width = 82

	local date_module = module(margin(date, 9, 9, 4, 4), module_bg)

	-----------------------------------------------------------------
	-- BATTERY MODULE
	-----------------------------------------------------------------

	local battery_module = module(margin(battery, 8, 8, 4, 4), module_bg)

	-----------------------------------------------------------------
	-- LAYOUT BOX
	-----------------------------------------------------------------

	local layoutbox = awful.widget.layoutbox(s)

	layoutbox.forced_width = 20
	layoutbox.forced_height = 20
	layoutbox.opacity = 0.7

	layoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),

		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),

		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),

		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))

	local layout_module = module(margin(layoutbox, 7, 7, 3, 3), module_bg)

	-----------------------------------------------------------------
	-- SYSTEM TRAY
	-----------------------------------------------------------------

	local systray = wibox.widget.systray()

	systray.base_size = 14

	local systray_module = module(margin(systray, 7, 7, 3, 3), module_bg)

	-----------------------------------------------------------------
	-- WIBAR
	-----------------------------------------------------------------

	local wibar = awful.wibar({
		position = "top",

		screen = s,

		height = 34,

		bg = bar_bg,
		fg = fg,

		border_width = 0,
		shape = gears.shape.rectangle,
	})

	-----------------------------------------------------------------
	-- WIBAR LAYOUT
	-----------------------------------------------------------------

	wibar:setup({
		layout = wibox.layout.align.horizontal,

		-------------------------------------------------------------
		-- LEFT
		-------------------------------------------------------------

		{
			layout = wibox.layout.fixed.horizontal,

			margin(taglist, 7, 5, 3, 3),

			margin(promptbox, 7, 7, 0, 0),
		},

		-------------------------------------------------------------
		-- CENTER
		-------------------------------------------------------------

		{
			layout = wibox.layout.flex.horizontal,

			margin(tasklist, 8, 8, 3, 3),
		},

		-------------------------------------------------------------
		-- RIGHT
		-------------------------------------------------------------

		{
			layout = wibox.layout.fixed.horizontal,

			margin(power_module, 3, 3, 2, 2),

			margin(systray_module, 3, 3, 2, 2),

			margin(battery_module, 3, 3, 2, 2),

			margin(date_module, 3, 3, 2, 2),

			margin(clock_module, 3, 6, 2, 2),

			margin(layout_module, 2, 4, 2, 2),
		},
	})

	-----------------------------------------------------------------
	-- KEEP REFERENCES ON THE SCREEN
	-----------------------------------------------------------------

	s.mytaglist = taglist
	s.mytasklist = tasklist
	s.mypromptbox = promptbox
	s.mylayoutbox = layoutbox
	s.mywibox = wibar
end

---------------------------------------------------------------------
-- MODULE EXPORT
---------------------------------------------------------------------

return {
	setup = setup,
}
