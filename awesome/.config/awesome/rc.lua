pcall(require, "luarocks.loader")
-------------------------------------------------------------------
---Standard awesome library
-------------------------------------------------------------------
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local volume_osd = require("volume_osd")
local clipboard = require("clipboard")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
require("awful.hotkeys_popup.keys")
--
--
--
--
--
-------------------------------------------------------------------
--- Startup Commands
-------------------------------------------------------------------
awful.spawn.with_shell("dunst")
awful.spawn.with_shell("pipewire")
awful.spawn.with_shell("picom -b")
awful.spawn.with_shell(" ~/.config/awesome/clipboard-watch.sh")
--awful.spawn.with_shell("gsr-ui")
--
--
--
--
--
-------------------------------------------------------------------
-- some settings
-------------------------------------------------------------------
awful.spawn("xset r rate 200 35")
awful.spawn("xset s off")
awful.spawn("xset -dpms")
--
--
--
--
--
-------------------------------------------------------------------
--- Error Handling
-------------------------------------------------------------------
-- {{{ Error handling
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}
--
--
--
--
--
-------------------------------------------------------------------
--- Variable Definitions and Theme
-------------------------------------------------------------------
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/elric/theme.lua")
beautiful.font = "JetBrainsMono Nerd Font 9"

terminal = "ghostty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
beautiful.useless_gap = 3

modkey = "Mod4"
--
--
--
--
--
-------------------------------------------------------------------
--- HDMI Configs
-------------------------------------------------------------------
-- Monitor
awful.spawn.with_shell("xrandr --output HDMI-1-0 --mode 1280x960 --rate 60 --left-of eDP-1")

-- TV / Projector
--awful.spawn.with_shell("xrandr --output HDMI-1-0 --auto --right-of eDP-1")
-- TV / Projector mirroring
--awful.spawn.with_shell("xrandr --output HDMI-1-0 --auto --same-as eDP-1")
---
---
---
---
---
-------------------------------------------------------------------
-- Table of Layouts to cover with awful.layout.inc, order matters.
-------------------------------------------------------------------
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
	--awful.layout.suit.fair,
	--awful.layout.suit.tile.left,
	--awful.layout.suit.tile.bottom,
	--awful.layout.suit.tile.top,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	--awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	--awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
--
--
--
--
--
-------------------------------------------------------------------
-- Keyboard map indicator and switcher
-------------------------------------------------------------------
mykeyboardlayout = awful.widget.keyboardlayout()
mykeyboardlayout.font = "JetBrainsMono Nerd Font 9"
mykeyboardlayout.forced_width = 28
--
--
--
--
--
-------------------------------------------------------------------
--- Wibar
-------------------------------------------------------------------
-- Create a textclock widget
mytextclock = wibox.widget.textclock("%a %d %b  •  %H:%M")
mytextclock.font = "JetBrainsMono Nerd Font Bold 9"
mytextclock.fg = "#f2f2f2"
mytextclock.align = "center"

-- Battery percentage
local battery = wibox.widget.textbox()
battery.font = "JetBrainsMono Nerd Font 9"
battery.align = "center"
battery.forced_width = 62

local function update_battery()
	awful.spawn.easy_async_with_shell("cat /sys/class/power_supply/BAT0/capacity", function(stdout)
		local percent = stdout:match("%d+")

		if percent then
			battery.text = string.format("BAT %3d%%", tonumber(percent))
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

-- Create a wibox for each screen and add it
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

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)
--
--
--
--
--
-------------------------------------------------------------------
--- Wallpaper
-------------------------------------------------------------------
local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)
	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	s.mypromptbox = awful.widget.prompt()
	-- ================================================================
	--                    SLICK MONOCHROME WIBAR
	-- ================================================================

	local function margin(widget, left, right, top, bottom)
		return wibox.container.margin(widget, left or 0, right or 0, top or 0, bottom or 0)
	end

	-- Workspaces: tiny numbers, no oversized glyphs/icons.
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		layout = {
			spacing = 1,
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					id = "text_role",
					align = "center",
					valign = "center",
					widget = wibox.widget.textbox,
				},
				left = 5,
				right = 5,
				top = 1,
				bottom = 1,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
			shape = gears.shape.rounded_rect,
		},
	})

	local systray = wibox.widget.systray()
	systray.base_size = 14

	-- Applications: text-first tasklist, keeping the module but removing icon bulk.
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		widget_template = {
			{
				{
					id = "text_role",
					align = "center",
					valign = "center",
					widget = wibox.widget.textbox,
				},
				left = 7,
				right = 7,
				top = 1,
				bottom = 1,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
		},
	})

	-- Layout switcher: constrained so its icon cannot dominate the bar.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox.forced_width = 18
	s.mylayoutbox.forced_height = 18
	s.mylayoutbox.opacity = 0.75

	s.mylayoutbox:buttons(gears.table.join(
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

	s.mywibox = awful.wibar({
		position = "top",
		screen = s,
		height = 26,
		bg = "#090909",
		fg = "#a8a8a8",
		border_width = 0,
		shape = gears.shape.rectangle,
	})

	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,

		-- LEFT — workspaces + prompt
		{
			layout = wibox.layout.fixed.horizontal,
			margin(s.mytaglist, 4, 4, 2, 2),
			margin(s.mypromptbox, 5, 5, 0, 0),
		},

		-- CENTER — active applications
		{
			layout = wibox.layout.flex.horizontal,
			margin(s.mytasklist, 6, 6, 2, 2),
		},

		-- RIGHT — system modules + clock
		{
			layout = wibox.layout.fixed.horizontal,
			margin(mykeyboardlayout, 3, 3, 0, 0),
			margin(systray, 3, 3, 0, 0),
			margin(wibox.widget.textbox("│"), 1, 1, 0, 0),
			margin(battery, 4, 4, 0, 0),
			margin(wibox.widget.textbox("│"), 1, 1, 0, 0),
			margin(mytextclock, 7, 7, 0, 0),
			margin(s.mylayoutbox, 3, 5, 0, 0),
		},
	})
	--
	--
	--
	--
	--- Keybinds
	-------------------------------------------------------------------
	globalkeys = gears.table.join(
		awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
		awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
		awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
		awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

		awful.key({ modkey }, "j", function()
			awful.client.focus.byidx(1)
		end, { description = "focus next by index", group = "client" }),
		awful.key({ modkey }, "k", function()
			awful.client.focus.byidx(-1)
		end, { description = "focus previous by index", group = "client" }),

		-- Layout manipulation
		awful.key({ modkey, "Shift" }, "j", function()
			awful.client.swap.byidx(1)
		end, { description = "swap with next client by index", group = "client" }),
		awful.key({ modkey, "Shift" }, "k", function()
			awful.client.swap.byidx(-1)
		end, { description = "swap with previous client by index", group = "client" }),
		awful.key({ modkey, "Control" }, "j", function()
			awful.screen.focus_relative(1)
		end, { description = "focus the next screen", group = "screen" }),
		awful.key({ modkey, "Control" }, "k", function()
			awful.screen.focus_relative(-1)
		end, { description = "focus the previous screen", group = "screen" }),
		awful.key(
			{ modkey },
			"u",
			awful.client.urgent.jumpto,
			{ description = "jump to urgent client", group = "client" }
		),
		awful.key({ modkey }, "Tab", function()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end, { description = "go back", group = "client" }),

		-- Previous workspace
		awful.key({ modkey }, "u", function()
			awful.tag.viewprev()
		end),

		-- Next workspace
		awful.key({ modkey }, "i", function()
			awful.tag.viewnext()
		end),

		-- Standard program
		awful.key({ modkey }, "x", function()
			awful.spawn(terminal)
		end, { description = "open a terminal", group = "launcher" }),
		awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
		awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
		awful.key({ modkey }, "Escape", function()
			awful.spawn.with_shell("loginctl poweroff")
		end),
		awful.key({ "Control", "Shift" }, "r", function()
			awful.spawn.with_shell("loginctl reboot")
		end),

		awful.key({ modkey }, "l", function()
			awful.tag.incmwfact(0.05)
		end, { description = "increase master width factor", group = "layout" }),
		awful.key({ modkey }, "h", function()
			awful.tag.incmwfact(-0.05)
		end, { description = "decrease master width factor", group = "layout" }),
		awful.key({ modkey, "Shift" }, "h", function()
			awful.tag.incnmaster(1, nil, true)
		end, { description = "increase the number of master clients", group = "layout" }),
		awful.key({ modkey, "Shift" }, "l", function()
			awful.tag.incnmaster(-1, nil, true)
		end, { description = "decrease the number of master clients", group = "layout" }),
		awful.key({ modkey, "Control" }, "h", function()
			awful.tag.incncol(1, nil, true)
		end, { description = "increase the number of columns", group = "layout" }),
		awful.key({ modkey, "Control" }, "l", function()
			awful.tag.incncol(-1, nil, true)
		end, { description = "decrease the number of columns", group = "layout" }),
		awful.key({ modkey }, "space", function()
			awful.layout.inc(1)
		end, { description = "select next", group = "layout" }),
		awful.key({ modkey, "Shift" }, "space", function()
			awful.layout.inc(-1)
		end, { description = "select previous", group = "layout" }),

		awful.key({ modkey, "Control" }, "n", function()
			local c = awful.client.restore()
			-- Focus restored client
			if c then
				c:emit_signal("request::activate", "key.unminimize", { raise = true })
			end
		end, { description = "restore minimized", group = "client" }),

		-- for rofi
		awful.key({ modkey, "Shift" }, "p", function()
			awful.spawn.with_shell("pgrep rofi && pkill rofi || rofi -show drun")
		end),

		awful.key({ modkey, "Shift" }, "x", function()
			awful.prompt.run({
				prompt = "Run Lua code: ",
				textbox = awful.screen.focused().mypromptbox.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval",
			})
		end, { description = "lua execute prompt", group = "awesome" }),
		-- Clipboard
		awful.key({ modkey }, "v", function()
			clipboard.toggle()
		end, { description = "clipboard history", group = "launcher" }),
		-- Menubar
		awful.key({ modkey }, "p", function()
			menubar.show()
		end, { description = "show the menubar", group = "launcher" }),

		-- Applications
		awful.key({ modkey, "Shift" }, "v", function()
			awful.spawn("vivado")
		end, { description = "open Vivado", group = "launcher" }),

		awful.key({ modkey }, "b", function()
			awful.spawn("zen")
		end, { description = "open Zen Browser", group = "launcher" }),

		awful.key({ modkey }, "y", function()
			awful.spawn("ghostty -e yazi")
		end, { description = "open Yazi", group = "launcher" }),

		awful.key({ modkey }, "d", function()
			awful.spawn("ghostty -e endcord")
		end, { description = "open Endcord", group = "launcher" }),

		awful.key({ modkey }, "e", function()
			awful.spawn("ghostty -e aerc")
		end, { description = "open aerc", group = "launcher" }),

		awful.key({ modkey, "Shift" }, "d", function()
			awful.spawn.with_shell("dbus-run-session flatpak run com.discordapp.Discord")
		end, { description = "open Discord", group = "launcher" }),

		awful.key({ modkey, "Shift" }, "b", function()
			awful.spawn("blender")
		end, { description = "open Blender", group = "launcher" }),

		awful.key({ modkey }, "g", function()
			awful.spawn.with_shell("pgrep -x gsr-ui >/dev/null && pkill -x gsr-ui || gsr-ui")
		end, { description = "toggle GPU screen recorder", group = "launcher" }),

		awful.key({ modkey, "Shift" }, "g", function()
			awful.spawn.with_shell("~/dotfiles/Scripts/copy-ss.sh")
		end, { description = "copy screenshot", group = "launcher" }),

		awful.key({ modkey }, "r", function()
			awful.spawn.with_shell("wine ~/Applications/reaper/reaper.exe")
		end, { description = "open Reaper", group = "launcher" }),

		awful.key({ modkey }, "c", function()
			awful.spawn.with_shell("npm --prefix ~/Lost/Programming/Rust/Tauri/Lumus run tauri dev")
		end, { description = "launch Lumus", group = "launcher" }),

		awful.key({ modkey, "Shift" }, "c", function()
			awful.spawn.with_shell(
				"firejail --net=none wine ~/.wine/drive_c/'Program Files'/'Cisco Packet Tracer 8.2.2'/bin/PacketTracer.exe"
			)
		end, { description = "open Cisco Packet Tracer", group = "launcher" }),

		awful.key({ modkey }, "n", function()
			awful.spawn.with_shell([[
            redshift -O 3400
    ]])
		end, { description = " night light", group = "system" }),

		awful.key({ modkey, "Shift" }, "n", function()
			awful.spawn.with_shell([[
            redshift -x
    ]])
		end, { description = "toggle night light", group = "system" }),

		-- Volume
		awful.key({}, "XF86AudioLowerVolume", function()
			awful.spawn.with_shell("pamixer -d 10")
			gears.timer.start_new(0.05, function()
				volume_osd.show()
				return false
			end)
		end, { description = "decrease volume", group = "audio" }),

		awful.key({}, "XF86AudioRaiseVolume", function()
			awful.spawn.with_shell("pamixer -i 10")
			gears.timer.start_new(0.05, function()
				volume_osd.show()
				return false
			end)
		end, { description = "increase volume", group = "audio" }),

		awful.key({}, "XF86AudioMute", function()
			awful.spawn.with_shell("pamixer -t")
			gears.timer.start_new(0.05, function()
				volume_osd.show()
				return false
			end)
		end, { description = "toggle mute", group = "audio" }),

		-- Brightness
		awful.key({}, "F12", function()
			awful.spawn.with_shell("brightnessctl s +5%")
		end, { description = "increase brightness", group = "hardware" }),

		awful.key({}, "F11", function()
			awful.spawn.with_shell("brightnessctl s 5%-")
		end, { description = "decrease brightness", group = "hardware" }),

		awful.key({}, "XF86MonBrightnessUp", function()
			awful.spawn.with_shell("brightnessctl s +5%")
		end, { description = "increase brightness", group = "hardware" }),

		awful.key({}, "XF86MonBrightnessDown", function()
			awful.spawn.with_shell("brightnessctl s 5%-")
		end, { description = "decrease brightness", group = "hardware" }),

		-- Session / power
		awful.key({ "Control", "Shift" }, "r", function()
			awful.spawn.with_shell("loginctl reboot")
		end, { description = "reboot", group = "system" }),

		-- Niri's Mod+Escape is kept as requested, while Awesome's existing
		-- bindings remain otherwise unchanged.
		awful.key({ modkey }, "Escape", function()
			awful.spawn.with_shell("loginctl poweroff")
		end, { description = "power off", group = "system" }),

		awful.key({ modkey, "Shift" }, "Home", function()
			local s = awful.screen.focused()
			if s.tags[1] then
				s.tags[1]:view_only()
			end
		end, { description = "focus first workspace", group = "tag" }),

		awful.key({ modkey, "Shift" }, "End", function()
			local s = awful.screen.focused()
			if s.tags[9] then
				s.tags[9]:view_only()
			end
		end, { description = "focus last workspace", group = "tag" }),

		-- Move focused client to the first/last tag.
		awful.key({ modkey, "Control", "Shift" }, "Home", function()
			if client.focus and client.focus.screen.tags[1] then
				client.focus:move_to_tag(client.focus.screen.tags[1])
			end
		end, { description = "move client to first workspace", group = "tag" }),

		awful.key({ modkey, "Control", "Shift" }, "End", function()
			if client.focus and client.focus.screen.tags[9] then
				client.focus:move_to_tag(client.focus.screen.tags[9])
			end
		end, { description = "move client to last workspace", group = "tag" })
	)

	clientkeys = gears.table.join(
		awful.key({ modkey }, "f", function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end, { description = "toggle fullscreen", group = "client" }),
		awful.key({ modkey }, "q", function(c)
			c:kill()
		end, { description = "close", group = "client" }),
		awful.key(
			{ modkey, "Control" },
			"space",
			awful.client.floating.toggle,
			{ description = "toggle floating", group = "client" }
		),
		awful.key({ modkey, "Control" }, "Return", function(c)
			c:swap(awful.client.getmaster())
		end, { description = "move to master", group = "client" }),
		awful.key({ modkey }, "o", function(c)
			c:move_to_screen()
		end, { description = "move to screen", group = "client" }),
		awful.key({ modkey }, "t", function(c)
			c.ontop = not c.ontop
		end, { description = "toggle keep on top", group = "client" }),
		awful.key({ modkey }, "n", function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end, { description = "minimize", group = "client" }),
		awful.key({ modkey }, "m", function(c)
			c.maximized = not c.maximized
			c:raise()
		end, { description = "(un)maximize", group = "client" }),
		awful.key({ modkey, "Control" }, "m", function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end, { description = "(un)maximize vertically", group = "client" }),
		awful.key({ modkey, "Shift" }, "m", function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end, { description = "(un)maximize horizontally", group = "client" })
	)
	--
	--
	--
	--
	--
	-------------------------------------------------------------------
	--- Workspace binds
	-------------------------------------------------------------------
	for i = 1, 9 do
		globalkeys = gears.table.join(
			globalkeys,
			-- View tag only.
			awful.key({ modkey }, "#" .. i + 9, function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end, { description = "view tag #" .. i, group = "tag" }),
			-- Toggle tag display.
			awful.key({ modkey, "Control" }, "#" .. i + 9, function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end, { description = "toggle tag #" .. i, group = "tag" }),
			-- Move client to tag.
			awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end, { description = "move focused client to tag #" .. i, group = "tag" }),
			-- Toggle tag on focused client.
			awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end, { description = "toggle focused client on tag #" .. i, group = "tag" })
		)
	end

	clientbuttons = gears.table.join(
		awful.button({}, 1, function(c)
			c:emit_signal("request::activate", "mouse_click", { raise = true })
		end),
		awful.button({ modkey }, 1, function(c)
			c:emit_signal("request::activate", "mouse_click", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({ modkey }, 3, function(c)
			c:emit_signal("request::activate", "mouse_click", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)
	--
	--
	--
	--
	--
	-------------------------------------------------------------------
	-- Set keys
	-------------------------------------------------------------------
	root.keys(globalkeys)
	--
	--
	--
	--
	--
	-------------------------------------------------------------------
	--- Rules
	-------------------------------------------------------------------
	awful.rules.rules = {
		{
			rule = {},
			properties = {
				border_width = beautiful.border_width,
				border_color = beautiful.border_normal,
				focus = awful.client.focus.filter,
				raise = true,
				keys = clientkeys,
				buttons = clientbuttons,
				screen = awful.screen.preferred,
				placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			},
		},

		-- Floating clients.
		{
			rule_any = {
				instance = {
					"DTA", -- Firefox addon DownThemAll.
					"copyq", -- Includes session name in class.
					"pinentry",
				},
				class = {
					"Arandr",
					"Blueman-manager",
					"Gpick",
					"Kruler",
					"MessageWin", -- kalarm.
					"Sxiv",
					"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
					"Wpa_gui",
					"veromix",
					"xtightvncviewer",
				},

				name = {
					"Event Tester", -- xev.
				},
				role = {
					"AlarmWindow", -- Thunderbird's calendar.
					"ConfigManager", -- Thunderbird's about:config.
					"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
				},
			},
			properties = { floating = true },
		},

		{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },
	}

	-- {{{ Signals
	client.connect_signal("manage", function(c)
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- if not awesome.startup then awful.client.setslave(c) end

		if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end
	end)

	client.connect_signal("request::titlebars", function(c)
		-- buttons for the titlebar
		local buttons = gears.table.join(
			awful.button({}, 1, function()
				c:emit_signal("request::activate", "titlebar", { raise = true })
				awful.mouse.client.move(c)
			end),
			awful.button({}, 3, function()
				c:emit_signal("request::activate", "titlebar", { raise = true })
				awful.mouse.client.resize(c)
			end)
		)

		awful.titlebar(c):setup({
			{ -- Left
				awful.titlebar.widget.iconwidget(c),
				buttons = buttons,
				layout = wibox.layout.fixed.horizontal,
			},
			{ -- Middle
				{ -- Title
					align = "center",
					widget = awful.titlebar.widget.titlewidget(c),
				},
				buttons = buttons,
				layout = wibox.layout.flex.horizontal,
			},
			{ -- Right
				awful.titlebar.widget.floatingbutton(c),
				awful.titlebar.widget.maximizedbutton(c),
				awful.titlebar.widget.stickybutton(c),
				awful.titlebar.widget.ontopbutton(c),
				awful.titlebar.widget.closebutton(c),
				layout = wibox.layout.fixed.horizontal(),
			},
			layout = wibox.layout.align.horizontal,
		})
	end)

	beautiful.bg_normal = "#090909"
	beautiful.bg_focus = "#171717"
	beautiful.fg_normal = "#a8a8a8"
	beautiful.fg_focus = "#f2f2f2"
	beautiful.border_normal = "#242424"
	beautiful.border_focus = "#8a8a8a"
	beautiful.border_marked = "#5f5f5f"

	-- Enable sloppy focus, so that focus follows mouse.
	client.connect_signal("mouse::enter", function(c)
		c:emit_signal("request::activate", "mouse_enter", { raise = false })
	end)
	--
	client.connect_signal("focus", function(c)
		c.border_color = beautiful.border_focus
	end)
	client.connect_signal("unfocus", function(c)
		c.border_color = beautiful.border_normal
	end)
end)
