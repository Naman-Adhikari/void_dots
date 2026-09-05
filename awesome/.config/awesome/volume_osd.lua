local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local volume_osd = {}

-- ============================================================
-- Monochrome volume OSD
-- ============================================================

local popup
local hide_timer

local function create_popup(screen)
	-- Main popup
	popup = wibox({
		screen = screen,
		width = 300,
		height = 120,
		visible = false,
		ontop = true,
		type = "notification",
		bg = "#111111",
		fg = "#eeeeee",
		border_width = 1,
		border_color = "#444444",
		shape = gears.shape.rounded_rect,
	})

	-- Volume icon
	local icon = wibox.widget({
		text = "󰕾",
		font = "Sans 28",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	-- Percentage text
	local percentage = wibox.widget({
		text = "0%",
		font = "Sans Bold 16",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	-- Progress bar
	local progress = wibox.widget({
		max_value = 100,
		value = 0,
		forced_height = 8,
		shape = gears.shape.rounded_bar,

		background_color = "#333333",
		color = "#eeeeee",

		widget = wibox.widget.progressbar,
	})

	popup:setup({
		{
			{
				icon,
				percentage,
				spacing = 10,
				layout = wibox.layout.fixed.horizontal,
			},

			progress,

			spacing = 12,
			layout = wibox.layout.fixed.vertical,
		},

		margins = 22,
		widget = wibox.container.margin,
	})

	popup._icon = icon
	popup._percentage = percentage
	popup._progress = progress
end

local function update_icon(muted, volume)
	if muted then
		popup._icon.text = "󰖁"
	elseif volume == 0 then
		popup._icon.text = "󰕿"
	elseif volume < 50 then
		popup._icon.text = "󰖀"
	else
		popup._icon.text = "󰕾"
	end
end

function volume_osd.show()
	local screen = awful.screen.focused()

	if not popup then
		create_popup(screen)
	end

	-- Move popup to the currently focused screen
	popup.screen = screen

	awful.spawn.easy_async_with_shell("pamixer --get-volume --get-mute", function(stdout)
		local volume = stdout:match("(%d+)")
		local mute = stdout:match("true")

		volume = tonumber(volume) or 0
		local muted = mute ~= nil

		if muted then
			popup._percentage.text = "Muted"
			popup._progress.value = 0
		else
			popup._percentage.text = volume .. "%"
			popup._progress.value = volume
		end

		update_icon(muted, volume)

		-- Center on screen
		awful.placement.centered(popup, {
			parent = screen,
			margins = {
				top = -850,
			},
		})

		popup.visible = true

		-- Reset hide timer
		if hide_timer then
			hide_timer:stop()
		end

		hide_timer = gears.timer({
			timeout = 1.2,
			autostart = true,
			single_shot = true,
			callback = function()
				popup.visible = false
			end,
		})
	end)
end

return volume_osd
