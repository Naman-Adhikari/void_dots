local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local clipboard = {}

------------------------------------------------------------
-- State
------------------------------------------------------------

local popup = nil
local history = {}
local selected = 1

------------------------------------------------------------
-- History file
------------------------------------------------------------

local history_file = os.getenv("HOME") .. "/.cache/awesome/clipboard_history"

------------------------------------------------------------
-- Colors
------------------------------------------------------------

local BG = "#111313"
local BG_SELECTED = "#1b2721"
local BORDER = "#29312d"

local FG = "#e8eee9"
local FG_DIM = "#89958e"

local ACCENT = "#8fe3b0"

------------------------------------------------------------
-- Shell quote
--
-- gears.string.quote() is not available on your
-- AwesomeWM version, so we use our own.
------------------------------------------------------------

local function shell_quote(text)
	return "'" .. text:gsub("'", "'\\''") .. "'"
end

------------------------------------------------------------
-- Pango escape
------------------------------------------------------------

local function escape_markup(text)
	text = text:gsub("&", "&amp;")
	text = text:gsub("<", "&lt;")
	text = text:gsub(">", "&gt;")

	return text
end

------------------------------------------------------------
-- Create popup
------------------------------------------------------------

local function create_popup(screen)
	popup = wibox({
		screen = screen,

		width = 620,
		height = 420,

		visible = false,
		ontop = true,

		type = "normal",

		bg = BG,
		fg = FG,

		border_width = 1,
		border_color = BORDER,

		shape = gears.shape.rounded_rect,
	})

	--------------------------------------------------------
	-- Title
	--------------------------------------------------------

	local title = wibox.widget.textbox()

	title.markup = '<span foreground="'
		.. ACCENT
		.. '">󰅍</span>  '
		.. '<span foreground="'
		.. FG
		.. '"><b>CLIPBOARD</b></span>'
		.. '<span foreground="'
		.. FG_DIM
		.. '">  HISTORY</span>'

	title.font = "JetBrainsMono Nerd Font Bold 10"
	title.valign = "center"

	--------------------------------------------------------
	-- Hint
	--------------------------------------------------------

	local hint = wibox.widget.textbox()

	hint.markup = '<span foreground="' .. FG_DIM .. '">j/k navigate   •   enter paste   •   esc close</span>'

	hint.font = "JetBrainsMono Nerd Font 8"
	hint.valign = "center"

	--------------------------------------------------------
	-- Header
	--------------------------------------------------------

	local header = wibox.layout.align.horizontal()

	header:set_left(wibox.container.margin(title, 4, 0, 0, 0))

	header:set_right(wibox.container.margin(hint, 0, 4, 0, 0))

	--------------------------------------------------------
	-- Content
	--------------------------------------------------------

	local content = wibox.widget.textbox()

	content.markup = '<span foreground="' .. FG_DIM .. '">Loading clipboard history...</span>'

	content.font = "JetBrainsMono Nerd Font 9"
	content.valign = "top"

	--------------------------------------------------------
	-- Main layout
	--------------------------------------------------------

	local layout = wibox.layout.fixed.vertical()

	layout.spacing = 12

	layout:add(header)

	--------------------------------------------------------
	-- Divider
	--------------------------------------------------------

	local divider = wibox.widget({
		forced_height = 1,

		bg = BORDER,

		widget = wibox.container.background,
	})

	layout:add(divider)

	--------------------------------------------------------
	-- Content
	--------------------------------------------------------

	layout:add(wibox.container.margin(content, 6, 6, 0, 0))

	--------------------------------------------------------
	-- Padding
	--------------------------------------------------------

	popup.widget = wibox.container.margin(layout, 16, 16, 14, 14)

	popup._content = content
end

------------------------------------------------------------
-- Render history
------------------------------------------------------------

local function render_history()
	if not popup then
		return
	end

	--------------------------------------------------------
	-- Empty
	--------------------------------------------------------

	if #history == 0 then
		popup._content.markup = '<span foreground="' .. FG_DIM .. '">Clipboard history is empty.</span>'

		return
	end

	--------------------------------------------------------
	-- Build display
	--------------------------------------------------------

	local lines = {}

	for i, item in ipairs(history) do
		----------------------------------------------------
		-- Don't allow enormous clipboard entries to
		-- completely destroy the popup.
		----------------------------------------------------

		local display = item

		if #display > 180 then
			display = display:sub(1, 177) .. "..."
		end

		----------------------------------------------------
		-- Convert newlines into visible spaces
		----------------------------------------------------

		display = display:gsub("\r", "")
		display = display:gsub("\n", " ↵ ")

		----------------------------------------------------
		-- Escape Pango
		----------------------------------------------------

		display = escape_markup(display)

		----------------------------------------------------
		-- Selected
		----------------------------------------------------

		if i == selected then
			table.insert(
				lines,

				'<span background="'
					.. BG_SELECTED
					.. '" foreground="'
					.. ACCENT
					.. '">'
					.. "  ›  "
					.. display
					.. "  </span>"
			)

		----------------------------------------------------
		-- Normal
		----------------------------------------------------
		else
			table.insert(
				lines,

				'<span foreground="'
					.. FG_DIM
					.. '">    </span>'
					.. '<span foreground="'
					.. FG
					.. '">'
					.. display
					.. "</span>"
			)
		end
	end

	popup._content.markup = table.concat(lines, "\n")
end

------------------------------------------------------------
-- Load history
------------------------------------------------------------

local function load_history()
	awful.spawn.easy_async_with_shell("cat " .. shell_quote(history_file) .. " 2>/dev/null", function(stdout)
		history = {}

		------------------------------------------------
		-- No history
		------------------------------------------------

		if stdout == "" then
			selected = 0
			render_history()
			return
		end

		------------------------------------------------
		-- Decode each entry
		--
		-- We assign by index instead of table.insert()
		-- because the async commands may finish out
		-- of order.
		------------------------------------------------

		local count = 0

		for encoded in stdout:gmatch("[^\r\n]+") do
			count = count + 1

			local index = count

			awful.spawn.easy_async_with_shell("printf '%s' " .. shell_quote(encoded) .. " | base64 -d 2>/dev/null", function(
				decoded
			)
				history[index] = decoded

				------------------------------------------------
				-- Render after every decoded entry
				------------------------------------------------

				if index == 1 then
					selected = 1
				end

				render_history()
			end)
		end

		------------------------------------------------
		-- Safety
		------------------------------------------------

		if count == 0 then
			selected = 0
			render_history()
		end
	end)
end

------------------------------------------------------------
-- Close popup
------------------------------------------------------------

local function close_popup()
	awful.keygrabber.stop()

	if popup then
		popup.visible = false
	end
end

------------------------------------------------------------
-- Paste selected entry
------------------------------------------------------------

local function paste_selected()
	if #history == 0 then
		return
	end

	if not history[selected] then
		return
	end

	--------------------------------------------------------
	-- Save selected text
	--------------------------------------------------------

	local text = history[selected]

	--------------------------------------------------------
	-- Stop keyboard grabber
	--------------------------------------------------------

	awful.keygrabber.stop()

	--------------------------------------------------------
	-- Hide popup
	--------------------------------------------------------

	popup.visible = false

	--------------------------------------------------------
	-- Put selected text into X11 clipboard
	--------------------------------------------------------

	local command = "printf '%s' " .. shell_quote(text) .. " | xclip -selection clipboard"

	awful.spawn.easy_async_with_shell(command, function()
		------------------------------------------------
		-- Give xclip a moment to claim clipboard
		------------------------------------------------

		gears.timer.start_new(0.10, function()
			------------------------------------------------
			-- Paste into the previously focused window
			------------------------------------------------

			awful.spawn.with_shell("xdotool key --clearmodifiers ctrl+v")

			return false
		end)
	end)
end

------------------------------------------------------------
-- Select next
------------------------------------------------------------

local function select_next()
	if #history == 0 then
		return
	end

	selected = selected + 1

	if selected > #history then
		selected = 1
	end

	render_history()
end

------------------------------------------------------------
-- Select previous
------------------------------------------------------------

local function select_previous()
	if #history == 0 then
		return
	end

	selected = selected - 1

	if selected < 1 then
		selected = #history
	end

	render_history()
end

------------------------------------------------------------
-- Keyboard controls
------------------------------------------------------------

local function start_keygrabber()
	--------------------------------------------------------
	-- Stop any existing grabber
	--------------------------------------------------------

	awful.keygrabber.stop()

	--------------------------------------------------------
	-- Start new grabber
	--------------------------------------------------------

	awful.keygrabber.run(function(_, key, event)
		if event ~= "press" then
			return
		end

		------------------------------------------------
		-- Down / j
		------------------------------------------------

		if key == "j" or key == "Down" then
			select_next()

			------------------------------------------------
			-- Up / k
			------------------------------------------------
		elseif key == "k" or key == "Up" then
			select_previous()

			------------------------------------------------
			-- Enter
			------------------------------------------------
		elseif key == "Return" or key == "KP_Enter" then
			paste_selected()

			------------------------------------------------
			-- Escape
			------------------------------------------------
		elseif key == "Escape" then
			close_popup()
		end
	end)
end

------------------------------------------------------------
-- Show
------------------------------------------------------------

function clipboard.show()
	local screen = awful.screen.focused()

	--------------------------------------------------------
	-- Create popup
	--------------------------------------------------------

	if not popup then
		create_popup(screen)
	end

	--------------------------------------------------------
	-- Current screen
	--------------------------------------------------------

	popup.screen = screen

	--------------------------------------------------------
	-- Load history
	--------------------------------------------------------

	load_history()

	--------------------------------------------------------
	-- Position
	--------------------------------------------------------

	awful.placement.centered(popup, {
		parent = screen,

		margins = {
			top = -120,
		},
	})

	--------------------------------------------------------
	-- Show
	--------------------------------------------------------

	popup.visible = true

	--------------------------------------------------------
	-- Keyboard
	--------------------------------------------------------

	start_keygrabber()
end

------------------------------------------------------------
-- Toggle
------------------------------------------------------------

function clipboard.toggle()
	if popup and popup.visible then
		close_popup()
	else
		clipboard.show()
	end
end

return clipboard
