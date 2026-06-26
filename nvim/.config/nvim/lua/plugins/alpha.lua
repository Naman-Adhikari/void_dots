return {
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		local function footer()
			return {
				"",
				"󰥔 " .. os.date("%A %d %B %Y"),
				"󰔟 " .. os.date("%H:%M:%S"),
				"",
				"⚡ SYSTEM READY",
			}
		end

		dashboard.section.header.val = {
			[[██╗      ██████╗ ███████╗████████╗    ███╗   ██╗██╗   ██╗██╗███╗   ███╗]],
			[[██║     ██╔═══██╗██╔════╝╚══██╔══╝    ████╗  ██║██║   ██║██║████╗ ████║]],
			[[██║     ██║   ██║███████╗   ██║       ██╔██╗ ██║██║   ██║██║██╔████╔██║]],
			[[██║     ██║   ██║╚════██║   ██║       ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
			[[███████╗╚██████╔╝███████║   ██║       ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║]],
			[[╚══════╝ ╚═════╝ ╚══════╝   ╚═╝       ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
			[[                                                                       ]],
			[[                                                                       ]],
			[[                    ◇  LOST-NVIM TERMINAL CORE  ◇                     ]],
		}
		dashboard.section.buttons.val = {
			dashboard.button("e", "󰈔  New File", ":ene <BAR> startinsert<CR>"),
			dashboard.button("f", "󰱼  Find File", ":Telescope find_files<CR>"),
			dashboard.button("r", "󰄉  Recent Files", ":Telescope oldfiles<CR>"),
			dashboard.button("g", "󰱼  Live Grep", ":Telescope live_grep<CR>"),
			dashboard.button("c", "󰒓  Config", ":e ~/.config/nvim/init.lua<CR>"),
			dashboard.button("q", "󰗼  Quit", ":qa<CR>"),
		}

		dashboard.section.footer.val = footer()

		vim.cmd([[
	highlight AlphaHeader guifg=#1b5e20 gui=bold
	highlight AlphaButtons guifg=#2e7d32
	highlight AlphaFooter guifg=#4a6b4f
	highlight AlphaShortcut guifg=#355e3b gui=bold
]])

		dashboard.section.header.opts.hl = "AlphaHeader"
		dashboard.section.buttons.opts.hl = "AlphaButtons"
		dashboard.section.footer.opts.hl = "AlphaFooter"

		dashboard.config.layout = {
			{ type = "padding", val = 4 },
			dashboard.section.header,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			{ type = "padding", val = 2 },
			dashboard.section.footer,
		}

		alpha.setup(dashboard.config)
	end,
}
