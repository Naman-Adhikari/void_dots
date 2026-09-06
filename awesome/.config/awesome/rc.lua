pcall(require, "luarocks.loader")

-------------------------------------------------------------------
-- STANDARD AWESOME LIBRARIES
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

require("awful.hotkeys_popup.keys")

-------------------------------------------------------------------
-- WIBAR
-------------------------------------------------------------------

local wibar = require("wibar")

-------------------------------------------------------------------
-- STARTUP COMMANDS
-------------------------------------------------------------------

awful.spawn.with_shell("dunst")
awful.spawn.with_shell("pipewire")
awful.spawn.with_shell("picom -b")
awful.spawn.with_shell("~/.config/awesome/clipboard-watch.sh")

-------------------------------------------------------------------
-- X SETTINGS
-------------------------------------------------------------------

awful.spawn("xset r rate 200 35")
awful.spawn("xset s off")
awful.spawn("xset -dpms")

-------------------------------------------------------------------
-- ERROR HANDLING
-------------------------------------------------------------------

if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false

	awesome.connect_signal("debug::error", function(err)
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

-------------------------------------------------------------------
-- THEME / VARIABLES
-------------------------------------------------------------------

beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/elric/theme.lua")

beautiful.font = "JetBrainsMono Nerd Font 9"

terminal = "ghostty"

editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

beautiful.useless_gap = 3

modkey = "Mod4"

-------------------------------------------------------------------
-- COLORS
-------------------------------------------------------------------

beautiful.bg_normal = "#090909"
beautiful.bg_focus = "#171717"

beautiful.fg_normal = "#a8a8a8"
beautiful.fg_focus = "#f2f2f2"

beautiful.border_normal = "#242424"
beautiful.border_focus = "#8a8a8a"
beautiful.border_marked = "#5f5f5f"

-------------------------------------------------------------------
-- HDMI
-------------------------------------------------------------------

awful.spawn.with_shell("xrandr --output HDMI-1-0 --mode 1280x960 --rate 60 --left-of eDP-1")

-- TV / Projector
-- awful.spawn.with_shell(
--     "xrandr --output HDMI-1-0 --auto --right-of eDP-1"
-- )

-- TV / Projector mirroring
-- awful.spawn.with_shell(
--     "xrandr --output HDMI-1-0 --auto --same-as eDP-1"
-- )

-------------------------------------------------------------------
-- LAYOUTS
-------------------------------------------------------------------

awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,

	-- awful.layout.suit.fair,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,

	awful.layout.suit.max,

	-- awful.layout.suit.max.fullscreen,

	awful.layout.suit.magnifier,

	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}

-------------------------------------------------------------------
-- GLOBAL KEYS
-------------------------------------------------------------------

globalkeys = gears.table.join(

	-----------------------------------------------------------------
	-- AWESOME
	-----------------------------------------------------------------

	awful.key({ modkey }, "s", hotkeys_popup.show_help, {
		description = "show help",
		group = "awesome",
	}),

	awful.key({ modkey, "Shift" }, "r", awesome.restart, {
		description = "reload awesome",
		group = "awesome",
	}),

	awful.key({ modkey, "Shift" }, "q", awesome.quit, {
		description = "quit awesome",
		group = "awesome",
	}),

	-----------------------------------------------------------------
	-- WORKSPACE NAVIGATION
	-----------------------------------------------------------------

	awful.key({ modkey }, "Left", awful.tag.viewprev, {
		description = "view previous",
		group = "tag",
	}),

	awful.key({ modkey }, "Right", awful.tag.viewnext, {
		description = "view next",
		group = "tag",
	}),

	awful.key({ modkey }, "Escape", awful.tag.history.restore, {
		description = "go back",
		group = "tag",
	}),

	-----------------------------------------------------------------
	-- CLIENT FOCUS
	-----------------------------------------------------------------

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, {
		description = "focus next client",
		group = "client",
	}),

	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, {
		description = "focus previous client",
		group = "client",
	}),

	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()

		if client.focus then
			client.focus:raise()
		end
	end, {
		description = "go back",
		group = "client",
	}),

	awful.key({ modkey }, "u", awful.client.urgent.jumpto, {
		description = "jump to urgent client",
		group = "client",
	}),

	-----------------------------------------------------------------
	-- CLIENT SWAPPING
	-----------------------------------------------------------------

	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, {
		description = "swap with next client",
		group = "client",
	}),

	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, {
		description = "swap with previous client",
		group = "client",
	}),

	-----------------------------------------------------------------
	-- SCREEN NAVIGATION
	-----------------------------------------------------------------

	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, {
		description = "focus next screen",
		group = "screen",
	}),

	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, {
		description = "focus previous screen",
		group = "screen",
	}),

	-----------------------------------------------------------------
	-- WORKSPACE HISTORY
	-----------------------------------------------------------------

	awful.key({ modkey }, "i", function()
		awful.tag.viewnext()
	end, {
		description = "next workspace",
		group = "tag",
	}),

	-----------------------------------------------------------------
	-- TERMINAL
	-----------------------------------------------------------------

	awful.key({ modkey }, "x", function()
		awful.spawn(terminal)
	end, {
		description = "open terminal",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- POWER
	-----------------------------------------------------------------

	awful.key({ modkey }, "Escape", function()
		awful.spawn.with_shell("loginctl poweroff")
	end, {
		description = "power off",
		group = "system",
	}),

	awful.key({ "Control", "Shift" }, "r", function()
		awful.spawn.with_shell("loginctl reboot")
	end, {
		description = "reboot",
		group = "system",
	}),

	-----------------------------------------------------------------
	-- LAYOUT
	-----------------------------------------------------------------

	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, {
		description = "increase master width",
		group = "layout",
	}),

	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, {
		description = "decrease master width",
		group = "layout",
	}),

	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, {
		description = "increase master clients",
		group = "layout",
	}),

	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, {
		description = "decrease master clients",
		group = "layout",
	}),

	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, {
		description = "increase columns",
		group = "layout",
	}),

	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, {
		description = "decrease columns",
		group = "layout",
	}),

	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, {
		description = "select next layout",
		group = "layout",
	}),

	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, {
		description = "select previous layout",
		group = "layout",
	}),

	-----------------------------------------------------------------
	-- RESTORE MINIMIZED CLIENT
	-----------------------------------------------------------------

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()

		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, {
		description = "restore minimized",
		group = "client",
	}),

	-----------------------------------------------------------------
	-- ROFI
	-----------------------------------------------------------------

	awful.key({ modkey, "Shift" }, "p", function()
		awful.spawn.with_shell("pgrep rofi && pkill rofi || rofi -show drun")
	end, {
		description = "toggle rofi",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- LUA PROMPT
	-----------------------------------------------------------------

	awful.key({ modkey, "Shift" }, "x", function()
		local s = awful.screen.focused()

		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = s.mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, {
		description = "lua execute prompt",
		group = "awesome",
	}),

	-----------------------------------------------------------------
	-- CLIPBOARD
	-----------------------------------------------------------------

	awful.key({ modkey }, "v", function()
		clipboard.toggle()
	end, {
		description = "clipboard history",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- MENUBAR
	-----------------------------------------------------------------

	awful.key({ modkey }, "p", function()
		menubar.show()
	end, {
		description = "show menubar",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- APPLICATIONS
	-----------------------------------------------------------------

	awful.key({ modkey, "Shift" }, "v", function()
		awful.spawn("vivado")
	end, {
		description = "open Vivado",
		group = "launcher",
	}),

	awful.key({ modkey }, "b", function()
		awful.spawn("zen")
	end, {
		description = "open Zen Browser",
		group = "launcher",
	}),

	awful.key({ modkey }, "y", function()
		awful.spawn("ghostty -e yazi")
	end, {
		description = "open Yazi",
		group = "launcher",
	}),

	awful.key({ modkey }, "d", function()
		awful.spawn("ghostty -e endcord")
	end, {
		description = "open Endcord",
		group = "launcher",
	}),

	awful.key({ modkey }, "e", function()
		awful.spawn("ghostty -e aerc")
	end, {
		description = "open aerc",
		group = "launcher",
	}),

	awful.key({ modkey, "Shift" }, "d", function()
		awful.spawn.with_shell("dbus-run-session flatpak run com.discordapp.Discord")
	end, {
		description = "open Discord",
		group = "launcher",
	}),

	awful.key({ modkey, "Shift" }, "b", function()
		awful.spawn("blender")
	end, {
		description = "open Blender",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- GPU SCREEN RECORDER
	-----------------------------------------------------------------

	awful.key({ modkey }, "g", function()
		awful.spawn.with_shell("pgrep -x gsr-ui >/dev/null && pkill -x gsr-ui || gsr-ui")
	end, {
		description = "toggle GPU screen recorder",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- SCREENSHOT
	-----------------------------------------------------------------

	awful.key({ modkey, "Shift" }, "g", function()
		awful.spawn.with_shell("~/dotfiles/Scripts/copy-ss.sh")
	end, {
		description = "copy screenshot",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- REAPER
	-----------------------------------------------------------------

	awful.key({ modkey }, "r", function()
		awful.spawn.with_shell("wine ~/Applications/reaper/reaper.exe")
	end, {
		description = "open Reaper",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- LUMUS
	-----------------------------------------------------------------

	awful.key({ modkey }, "c", function()
		awful.spawn.with_shell("npm --prefix ~/Lost/Programming/Rust/Tauri/Lumus run tauri dev")
	end, {
		description = "launch Lumus",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- CISCO PACKET TRACER
	-----------------------------------------------------------------

	awful.key({ modkey, "Shift" }, "c", function()
		awful.spawn.with_shell(
			"firejail --net=none wine ~/.wine/drive_c/'Program Files'/'Cisco Packet Tracer 8.2.2'/bin/PacketTracer.exe"
		)
	end, {
		description = "open Cisco Packet Tracer",
		group = "launcher",
	}),

	-----------------------------------------------------------------
	-- NIGHT LIGHT
	-----------------------------------------------------------------

	awful.key({ modkey }, "n", function()
		awful.spawn.with_shell("redshift -O 3400")
	end, {
		description = "enable night light",
		group = "system",
	}),

	awful.key({ modkey, "Shift" }, "n", function()
		awful.spawn.with_shell("redshift -x")
	end, {
		description = "disable night light",
		group = "system",
	}),

	-----------------------------------------------------------------
	-- VOLUME
	-----------------------------------------------------------------

	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn.with_shell("pamixer -d 10")

		gears.timer.start_new(0.05, function()
			volume_osd.show()
			return false
		end)
	end, {
		description = "decrease volume",
		group = "audio",
	}),

	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn.with_shell("pamixer -i 10")

		gears.timer.start_new(0.05, function()
			volume_osd.show()
			return false
		end)
	end, {
		description = "increase volume",
		group = "audio",
	}),

	awful.key({}, "XF86AudioMute", function()
		awful.spawn.with_shell("pamixer -t")

		gears.timer.start_new(0.05, function()
			volume_osd.show()
			return false
		end)
	end, {
		description = "toggle mute",
		group = "audio",
	}),

	-----------------------------------------------------------------
	-- BRIGHTNESS
	-----------------------------------------------------------------

	awful.key({}, "F12", function()
		awful.spawn.with_shell("brightnessctl s +5%")
	end, {
		description = "increase brightness",
		group = "hardware",
	}),

	awful.key({}, "F11", function()
		awful.spawn.with_shell("brightnessctl s 5%-")
	end, {
		description = "decrease brightness",
		group = "hardware",
	}),

	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn.with_shell("brightnessctl s +5%")
	end, {
		description = "increase brightness",
		group = "hardware",
	}),

	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn.with_shell("brightnessctl s 5%-")
	end, {
		description = "decrease brightness",
		group = "hardware",
	}),

	-----------------------------------------------------------------
	-- FIRST WORKSPACE
	-----------------------------------------------------------------

	awful.key({ modkey, "Shift" }, "Home", function()
		local s = awful.screen.focused()

		if s.tags[1] then
			s.tags[1]:view_only()
		end
	end, {
		description = "focus first workspace",
		group = "tag",
	}),

	-----------------------------------------------------------------
	-- LAST WORKSPACE
	-----------------------------------------------------------------

	awful.key({ modkey, "Shift" }, "End", function()
		local s = awful.screen.focused()

		if s.tags[9] then
			s.tags[9]:view_only()
		end
	end, {
		description = "focus last workspace",
		group = "tag",
	}),

	-----------------------------------------------------------------
	-- MOVE CLIENT TO FIRST WORKSPACE
	-----------------------------------------------------------------

	awful.key({ modkey, "Control", "Shift" }, "Home", function()
		if client.focus and client.focus.screen.tags[1] then
			client.focus:move_to_tag(client.focus.screen.tags[1])
		end
	end, {
		description = "move client to first workspace",
		group = "tag",
	}),

	-----------------------------------------------------------------
	-- MOVE CLIENT TO LAST WORKSPACE
	-----------------------------------------------------------------

	awful.key({ modkey, "Control", "Shift" }, "End", function()
		if client.focus and client.focus.screen.tags[9] then
			client.focus:move_to_tag(client.focus.screen.tags[9])
		end
	end, {
		description = "move client to last workspace",
		group = "tag",
	})
)

-------------------------------------------------------------------
-- CLIENT KEYS
-------------------------------------------------------------------

clientkeys = gears.table.join(

	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, {
		description = "toggle fullscreen",
		group = "client",
	}),

	awful.key({ modkey }, "q", function(c)
		c:kill()
	end, {
		description = "close",
		group = "client",
	}),

	awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle, {
		description = "toggle floating",
		group = "client",
	}),

	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, {
		description = "move to master",
		group = "client",
	}),

	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, {
		description = "move to screen",
		group = "client",
	}),

	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, {
		description = "toggle keep on top",
		group = "client",
	}),

	awful.key({ modkey }, "n", function(c)
		c.minimized = true
	end, {
		description = "minimize",
		group = "client",
	}),

	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, {
		description = "(un)maximize",
		group = "client",
	}),

	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, {
		description = "(un)maximize vertically",
		group = "client",
	}),

	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal

		c:raise()
	end, {
		description = "(un)maximize horizontally",
		group = "client",
	})
)

-------------------------------------------------------------------
-- CLIENT MOUSE BUTTONS
-------------------------------------------------------------------

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

-------------------------------------------------------------------
-- WORKSPACE KEYBINDS
-------------------------------------------------------------------

for i = 1, 9 do
	-----------------------------------------------------------------
	-- VIEW TAG
	-----------------------------------------------------------------

	globalkeys = gears.table.join(
		globalkeys,

		awful.key({ modkey }, "#" .. i + 9, function()
			local s = awful.screen.focused()
			local tag = s.tags[i]

			if tag then
				tag:view_only()
			end
		end, {
			description = "view tag #" .. i,
			group = "tag",
		}),

		-----------------------------------------------------------------
		-- TOGGLE TAG
		-----------------------------------------------------------------

		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local s = awful.screen.focused()
			local tag = s.tags[i]

			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, {
			description = "toggle tag #" .. i,
			group = "tag",
		}),

		-----------------------------------------------------------------
		-- MOVE CLIENT TO TAG
		-----------------------------------------------------------------

		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]

				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, {
			description = "move client to tag #" .. i,
			group = "tag",
		}),

		-----------------------------------------------------------------
		-- TOGGLE CLIENT ON TAG
		-----------------------------------------------------------------

		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]

				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, {
			description = "toggle client on tag #" .. i,
			group = "tag",
		})
	)
end

-------------------------------------------------------------------
-- SET GLOBAL KEYS
-------------------------------------------------------------------

root.keys(globalkeys)

-------------------------------------------------------------------
-- RULES
-------------------------------------------------------------------

awful.rules.rules = {

	-----------------------------------------------------------------
	-- DEFAULT RULE
	-----------------------------------------------------------------

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

	-----------------------------------------------------------------
	-- FLOATING CLIENTS
	-----------------------------------------------------------------

	{
		rule_any = {

			instance = {
				"DTA",
				"copyq",
				"pinentry",
			},

			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin",
				"Sxiv",
				"Tor Browser",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			name = {
				"Event Tester",
			},

			role = {
				"AlarmWindow",
				"ConfigManager",
				"pop-up",
			},
		},

		properties = {
			floating = true,
		},
	},

	-----------------------------------------------------------------
	-- NO TITLEBARS
	-----------------------------------------------------------------

	{
		rule_any = {
			type = {
				"normal",
				"dialog",
			},
		},

		properties = {
			titlebars_enabled = false,
		},
	},
}

-------------------------------------------------------------------
-- CLIENT MANAGE SIGNAL
-------------------------------------------------------------------

client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
end)

-------------------------------------------------------------------
-- TITLEBARS
-------------------------------------------------------------------

client.connect_signal("request::titlebars", function(c)
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

		---------------------------------------------------------
		-- LEFT
		---------------------------------------------------------

		{
			awful.titlebar.widget.iconwidget(c),

			buttons = buttons,

			layout = wibox.layout.fixed.horizontal,
		},

		---------------------------------------------------------
		-- MIDDLE
		---------------------------------------------------------

		{
			{
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},

			buttons = buttons,

			layout = wibox.layout.flex.horizontal,
		},

		---------------------------------------------------------
		-- RIGHT
		---------------------------------------------------------

		{
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),

			layout = wibox.layout.fixed.horizontal,
		},

		layout = wibox.layout.align.horizontal,
	})
end)

-------------------------------------------------------------------
-- MOUSE FOCUS
-------------------------------------------------------------------

client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

-------------------------------------------------------------------
-- CLIENT BORDER COLORS
-------------------------------------------------------------------

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-------------------------------------------------------------------
-- SCREEN SETUP
-------------------------------------------------------------------

awful.screen.connect_for_each_screen(function(s)
	-----------------------------------------------------------------
	-- WORKSPACES
	-----------------------------------------------------------------

	awful.tag({
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
	}, s, awful.layout.layouts[1])

	-----------------------------------------------------------------
	-- WIBAR
	-----------------------------------------------------------------

	wibar.setup(s)
end)
