return {
	-- messages, cmdline and the popupmenu
	{
		"folke/noice.nvim",
		opts = function(_, opts)
			table.insert(opts.routes, {
				filter = {
					event = "notify",
					find = "No information available",
				},
				opts = { skip = true },
			})
			local focused = true
			vim.api.nvim_create_autocmd("FocusGained", {
				callback = function()
					focused = true
				end,
			})
			vim.api.nvim_create_autocmd("FocusLost", {
				callback = function()
					focused = false
				end,
			})
			table.insert(opts.routes, 1, {
				filter = {
					cond = function()
						return not focused
					end,
				},
				view = "notify_send",
				opts = { stop = false },
			})

			opts.commands = {
				all = {
					-- options for the message history that you get with `:Noice`
					view = "split",
					opts = { enter = true, format = "details" },
					filter = {},
				},
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function(event)
					vim.schedule(function()
						require("noice.text.markdown").keys(event.buf)
					end)
				end,
			})

			opts.presets.lsp_doc_border = true

			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			}

			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			}
		end,
	},

	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 3000, -- 3초 후 사라짐
			fps = 60, -- 기본값 30 → 60으로 증가 (더 부드러운 애니메이션)
			-- fps = 120, -- 매우 부드럽게 하려면 이걸로 변경
			stages = "fade_in_slide_out", -- 애니메이션 스타일
			render = "wrapped-compact", -- "default" | "wrapped-compact" | "minimal" (wrap 지원)
			top_down = true, -- true = 상단에서 아래로 (원래대로)
			max_width = 60, -- 최대 너비 60자 (조정 가능: 50, 70, 80 등)
			max_height = 10, -- 최대 높이 (줄 수)
			minimum_width = 30, -- 최소 너비
		},
	},

	{
		"snacks.nvim",
		opts = {
			scroll = { enabled = false },
		},
		keys = {},
	},

	-- buffer line
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		},
		opts = {
			options = {
				mode = "tabs",
				-- separator_style = "slant",
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
		},
	},

	-- filename
	{
		"b0o/incline.nvim",
		dependencies = { "craftzdog/solarized-osaka.nvim" },
		event = "BufReadPre",
		priority = 1200,
		config = function()
			local colors = require("solarized-osaka.colors").setup()
			require("incline").setup({
				highlight = {
					groups = {
						InclineNormal = { guibg = colors.magenta500, guifg = colors.base04, gui = "bold" },
						InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
					},
				},
				window = {
					margin = { vertical = 1, horizontal = 2 },
					padding = { left = 1, right = 1 },
					placement = { horizontal = "right", vertical = "top" },
				},
				hide = {
					cursorline = true,
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if vim.bo[props.buf].modified then
						filename = "[+] " .. filename
					end

					local icon, color = require("nvim-web-devicons").get_icon_color(filename)
					return { { icon, guifg = color }, { " " }, { filename } }
				end,
			})
		end,
	},

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			local LazyVim = require("lazyvim.util")
			opts.sections.lualine_c[4] = {
				LazyVim.lualine.pretty_path({
					length = 0,
					relative = "cwd",
					modified_hl = "MatchParen",
					directory_hl = "",
					filename_hl = "Bold",
					modified_sign = "",
					readonly_icon = " 󰌾 ",
				}),
			}
		end,
	},

	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		opts = {
			plugins = {
				gitsigns = true,
				tmux = true,
				kitty = { enabled = false, font = "+2" },
			},
		},
		keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
	},

	{
		"folke/snacks.nvim",
		opts = function()
			return {
				dashboard = {
					preset = {
						header = [[
       _         __                                       _ 
      (_)__  __ / /_   __  __ ___   ____   ____   ____   (_)
     / // / / // __ \ / / / // _ \ / __ \ / __ \ / __ \ / / 
    / // /_/ // / / // /_/ //  __// /_/ // / / // / / // /  
 __/ / \__,_//_/ /_/ \__, / \___/ \____//_/ /_//_/ /_//_/   
/___/               /____/                                  
            ]],
					},
				},
			}
		end,
	},
	{
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({
				mappings = {}, -- Empty mappings, we'll set them up manually
				hide_cursor = true,
				stop_eof = true,
				respect_scrolloff = false,
				cursor_scrolls_alone = true,
				easing_function = "quadratic", -- sine, circular, cubic, quartic, quintic
				pre_hook = nil,
				post_hook = nil,
				performance_mode = false,
			})

			-- 커스텀 스크롤 시간 - Using helper functions instead of set_mappings()
			local neoscroll = require("neoscroll")
			local keymap = {
				["<C-u>"] = function() neoscroll.ctrl_u({ duration = 100 }) end,
				["<C-d>"] = function() neoscroll.ctrl_d({ duration = 100 }) end,
				["<C-b>"] = function() neoscroll.ctrl_b({ duration = 250 }) end,
				["<C-f>"] = function() neoscroll.ctrl_f({ duration = 250 }) end,
				["<C-y>"] = function() neoscroll.scroll(-0.1, { move_cursor = false, duration = 100 }) end,
				["<C-e>"] = function() neoscroll.scroll(0.1, { move_cursor = false, duration = 100 }) end,
				["zt"] = function() neoscroll.zt({ half_win_duration = 100 }) end,
				["zz"] = function() neoscroll.zz({ half_win_duration = 100 }) end,
				["zb"] = function() neoscroll.zb({ half_win_duration = 100 }) end,
			}
			local modes = { "n", "v", "x" }
			for key, func in pairs(keymap) do
				vim.keymap.set(modes, key, func)
			end
		end,
	},
	{
		"sphamba/smear-cursor.nvim",
		opts = {
			distance_stop_animating = 0.8,

			-- Smooth cursor without smear
			stiffness = 0.5,
			trailing_stiffness = 0.5,
			matrix_pixel_threshold = 0.5,

			-- Fire harzard
			-- cursor_color = "#ff8800",
			-- stiffness = 0.3,
			-- trailing_stiffness = 0.1,
			-- trailing_exponent = 5,
			-- hide_target_hack = true,
			-- gamma = 1,
		},
	},
}
