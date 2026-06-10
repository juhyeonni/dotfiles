return {
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
		},
		keys = {
			{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
			{ "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
			{ "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
			{ "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
		},
	},

	{
		"folke/flash.nvim",
		---@type Flash.Config
		opts = {
			search = {
				forward = true,
				multi_window = false,
				wrap = false,
				incremental = true,
			},
		},
	},

	{
		"nvim-mini/mini.hipatterns",
		event = "BufReadPre",
		opts = {
			highlighters = {
				hsl_color = {
					pattern = "hsl%(%d+,? %d+%%?,? %d+%%?%)",
					group = function(_, match)
						local nh, ns, nl = match:match("hsl%((%d+),? (%d+)%%?,? (%d+)%%?%)")
						local h, s, l = tonumber(nh), tonumber(ns), tonumber(nl)
						local hex_color = require("craftzdog.hsl").hslToHex(h, s, l)
						return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
					end,
				},
			},
		},
	},

	{
		"dinhhuy258/git.nvim",
		event = "BufReadPre",
		opts = {
			keymaps = {
				-- Open blame window
				blame = "<Leader>gb",
				-- Open file/folder in git repository
				browse = "<Leader>go",
			},
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			"nvim-telescope/telescope-file-browser.nvim",
		},
		keys = {
			{
				"<leader>fP",
				function()
					require("telescope.builtin").find_files({
						cwd = require("lazy.core.config").options.root,
					})
				end,
				desc = "Find Plugin File",
			},
			{
				";f",
				function()
					local builtin = require("telescope.builtin")
					builtin.find_files({
						no_ignore = false,
						hidden = true,
					})
				end,
				desc = "Lists files in your current working directory, respects .gitignore",
			},
			{
				";r",
				function()
					local builtin = require("telescope.builtin")
					builtin.live_grep({
						additional_args = { "--hidden" },
					})
				end,
				desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
			},
			{
				"\\\\",
				function()
					local builtin = require("telescope.builtin")
					builtin.buffers()
				end,
				desc = "Lists open buffers",
			},
			{
				";t",
				function()
					local builtin = require("telescope.builtin")
					builtin.help_tags()
				end,
				desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
			},
			{
				";;",
				function()
					local builtin = require("telescope.builtin")
					builtin.resume()
				end,
				desc = "Resume the previous telescope picker",
			},
			{
				";e",
				function()
					local builtin = require("telescope.builtin")
					builtin.diagnostics()
				end,
				desc = "Lists Diagnostics for all open buffers or a specific buffer",
			},
			{
				";s",
				function()
					local builtin = require("telescope.builtin")
					builtin.treesitter()
				end,
				desc = "Lists Function names, variables, from Treesitter",
			},
			{
				"<leader>fB",
				function()
					local telescope = require("telescope")

					local function telescope_buffer_dir()
						return vim.fn.expand("%:p:h")
					end

					telescope.extensions.file_browser.file_browser({
						path = "%:p:h",
						cwd = telescope_buffer_dir(),
						respect_gitignore = false,
						hidden = true,
						grouped = true,
						previewer = false,
						initial_mode = "normal",
						layout_config = { height = 40 },
					})
				end,
				desc = "Open File Browser with the path of the current buffer",
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local fb_actions = require("telescope").extensions.file_browser.actions

			-- 기본값 초기화
			opts = opts or {}
			opts.defaults = opts.defaults or {}
			opts.extensions = opts.extensions or {}

			opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
				wrap_results = true,
				layout_strategy = "horizontal",
				layout_config = { prompt_position = "top" },
				sorting_strategy = "ascending",
				winblend = 0,
				mappings = {
					n = {},
				},
			})
			opts.pickers = {
				diagnostics = {
					theme = "ivy",
					initial_mode = "normal",
					layout_config = {
						preview_cutoff = 9999,
					},
				},
			}
			opts.extensions = {
				file_browser = {
					theme = "dropdown",
					-- disables netrw and use telescope-file-browser in its place
					hijack_netrw = true,
					mappings = {
						-- your custom insert mode mappings
						["n"] = {
							-- your custom normal mode mappings
							["N"] = fb_actions.create,
							["h"] = fb_actions.goto_parent_dir,
							["/"] = function()
								vim.cmd("startinsert")
							end,
							["<C-u>"] = function(prompt_bufnr)
								for i = 1, 10 do
									actions.move_selection_previous(prompt_bufnr)
								end
							end,
							["<C-d>"] = function(prompt_bufnr)
								for i = 1, 10 do
									actions.move_selection_next(prompt_bufnr)
								end
							end,
							["<PageUp>"] = actions.preview_scrolling_up,
							["<PageDown>"] = actions.preview_scrolling_down,
						},
					},
				},
			}
			telescope.setup(opts)
			require("telescope").load_extension("fzf")
			require("telescope").load_extension("file_browser")
		end,
	},

	{
		"saghen/blink.cmp",
		opts = {
			completion = {
				menu = {
					winblend = vim.o.pumblend,
				},
			},
			signature = {
				window = {
					winblend = vim.o.pumblend,
				},
			},
		},
	},

	{ "wakatime/vim-wakatime", lazy = false },

	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
		opts = {
			-- 커서가 있는 줄만 raw 마크업을 보여줌(편집 편의), 나머지는 렌더
			anti_conceal = { enabled = true },
			-- 헤딩 레벨에 따라 본문을 들여써서 문서처럼 계층이 보이게 함
			indent = {
				enabled = true,
				per_level = 2, -- 레벨당 들여쓰기 칸 수
				skip_level = 1, -- H1 아래 본문은 들여쓰지 않음(최상위는 평평하게)
				skip_heading = false,
			},
			heading = {
				sign = false,
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
				width = "full", -- 제목 줄 전체에 배경 바 → 섹션 구분 또렷
				border = true,
			},
			code = {
				sign = false,
				style = "full",
				width = "block",
				min_width = 40,
				right_pad = 2,
				left_pad = 1,
				border = "thin",
				language_icon = true,
				language_name = true,
			},
			bullet = {
				icons = { "● ", "○ ", "◆ ", "◇ " },
			},
			checkbox = {
				enabled = true,
				unchecked = { icon = "󰄱 " },
				checked = { icon = "󰱒 " },
			},
			pipe_table = {
				enabled = true,
				preset = "round", -- 둥근 모서리 테두리
				-- 'padded': 각 셀을 컬럼 최대 표시폭에 맞춰 패딩 → 소스가 들쭉날쭉해도 정렬됨
				-- (한글 등 CJK는 strdisplaywidth 기반 2칸으로 계산)
				cell = "padded",
				padding = 1,
				-- 정렬 행(:---, ---:, :--:)에 방향 표시
				alignment_indicator = "━",
				-- 위/아래 테두리를 virtual line으로 그려, 표 주변 빈 줄에 의존하지 않음
				border_virtual = true,
			},
			-- > [!NOTE] 같은 GitHub 콜아웃 강조 (기본 세트 사용)
			quote = { icon = "▎" },
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				end

				-- Navigation
				map("n", "]h", gs.next_hunk, "Next Hunk")
				map("n", "[h", gs.prev_hunk, "Prev Hunk")

				-- Actions
				map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
				map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage Hunk")
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset Hunk")

				map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
				map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")

				map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
				map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")

				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, "Blame Line")
				map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle Line Blame")

				map("n", "<leader>hd", gs.diffthis, "Diff This")
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, "Diff This ~")

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
			end,
		},
	},

	{
		"HakonHarnes/img-clip.nvim",
		opts = {},
	},
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch History" },
		},
		opts = {
			view = {
				default = { winbar_info = true },
				file_history = { winbar_info = true },
			},
		},
	},
	{
		"greggh/claude-code.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for git operations
		},
		config = function()
			require("claude-code").setup({
				window = {
					split_ratio = 0.3, -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
					position = "vertical", -- Position of the window: "botright", "topleft", "vertical", "rightbelow vsplit", etc.
					enter_insert = true, -- Whether to enter insert mode when opening Claude Code
					hide_numbers = true, -- Hide line numbers in the terminal window
					hide_signcolumn = true, -- Hide the sign column in the terminal window
				},
				keymaps = {
					toggle = {
						normal = "<C-\\><C-\\>",
						terminal = "<C-\\><C-\\>",
					},
				},
			})
		end,
	},
}
