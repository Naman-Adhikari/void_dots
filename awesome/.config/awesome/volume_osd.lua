local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local volume_osd = {}

local popup
local hide_timer

local function create_popup(screen)
	popup = wibox({
		screen = screen,

		width = 310,
		height = 52,

		visible = false,
		ontop = true,
		type = "normal",

		bg = "#151515",
		fg = "#eeeeee",

		border_width = 1,
		border_color = "#383838",

		shape = gears.shape.rounded_rect,
	})

	-- Speaker icon
	local icon = wibox.widget.textbox()

	icon.text = "󰕾"
	icon.font = "Symbols Nerd Font Mono 18"
	icon.align = "center"
	icon.valign = "center"

	-- Percentage
	local percentage = wibox.widget.textbox()

	percentage.text = "0%"
	percentage.font = "Sans Bold 12"
	percentage.align = "center"
	percentage.valign = "center"

	-- Volume progress bar
	local progress = wibox.widget({
		max_value = 100,
		value = 0,

		forced_width = 185,
		forced_height = 4,

		background_color = "#333333",
		color = "#eeeeee",

		shape = gears.shape.rounded_bar,

		widget = wibox.widget.progressbar,
	})

	-- Main horizontal layout
	local layout = wibox.layout.fixed.horizontal()

	layout.spacing = 14

	-- Icon
	layout:add(wibox.container.place(icon, {
		forced_width = 22,
		halign = "center",
		valign = "center",
	}))

	-- Progress bar
	layout:add(wibox.container.place(progress, {
		forced_width = 185,
		halign = "center",
		valign = "center",
	}))

	-- Percentage
	layout:add(wibox.container.place(percentage, {
		forced_width = 40,
		halign = "center",
		valign = "center",
	}))

	-- Outer padding
	popup.widget = wibox.container.margin(layout, 14, 14, 10, 10)

	popup._icon = icon
	popup._percentage = percentage
	popup._progress = progress
end

------------------------------------------------------------
-- Change speaker icon according to volume
------------------------------------------------------------

local function update_icon(volume, muted)
	if muted then
		-- Muted
		popup._icon.text = "󰖁"
	elseif volume == 0 then
		-- Zero volume
		popup._icon.text = "󰕿"
	elseif volume <= 30 then
		-- Low volume
		popup._icon.text = "󰕿"
	elseif volume <= 70 then
		-- Medium volume
		popup._icon.text = "󰖀"
	else
		-- High volume
		popup._icon.text = "󰕾"
	end
end

------------------------------------------------------------
-- Show OSD
------------------------------------------------------------

function volume_osd.show()
	local screen = awful.screen.focused()

	-- Create popup if it doesn't exist
	if not popup then
		create_popup(screen)
	end

	popup.screen = screen

	--------------------------------------------------------
	-- Get current volume
	--------------------------------------------------------

	awful.spawn.easy_async_with_shell("pamixer --get-volume --get-mute", function(stdout)
		local volume = stdout:match("(%d+)")
		local muted = stdout:match("true") ~= nil

		volume = tonumber(volume) or 0

		------------------------------------------------
		-- Update UI
		------------------------------------------------

		if muted then
			popup._percentage.text = "Muted"
			popup._progress.value = 0
		else
			popup._percentage.text = volume .. "%"
			popup._progress.value = volume
		end

		------------------------------------------------
		-- Update speaker icon
		------------------------------------------------

		update_icon(volume, muted)

		------------------------------------------------
		-- Position
		------------------------------------------------

		awful.placement.centered(popup, {
			parent = screen,

			margins = {
				top = -850,
			},
		})

		------------------------------------------------
		-- Show
		------------------------------------------------

		popup.visible = true

		------------------------------------------------
		-- Restart hide timer
		------------------------------------------------

		if hide_timer then
			hide_timer:stop()
		end

		hide_timer = gears.timer({
			timeout = 1.2,

			single_shot = true,

			callback = function()
				popup.visible = false
			end,
		})

		hide_timer:start()
	end)
end

return volume_osd
