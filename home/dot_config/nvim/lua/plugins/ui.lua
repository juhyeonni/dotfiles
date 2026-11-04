require("kanagawa").setup({
	colors = {
		theme = {
			all = {
				ui = {
					bg_gutter = "none",
				},
			},
		},
	},
	transparent = true,
	theme = "dragon",
	-- background takes precedence over theme, so both must be set
	background = { dark = "dragon", light = "lotus" },
})

vim.cmd.colorscheme("kanagawa")

-- mini.icons stands in for nvim-web-devicons, which lualine and others look for
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("which-key").setup({})

require("snacks").setup({
	scroll = { enabled = false },
	bigfile = { enabled = true },
	quickfile = { enabled = true },
	notifier = { enabled = true },
	picker = { enabled = true },
	dashboard = {
		enabled = true,
		preset = {
			header = [[
       _       __                                 _
      (_)_  __/ /_  __  _____  ____  ____  ____  (_)
     / / / / / __ \/ / / / _ \/ __ \/ __ \/ __ \/ /
    / / /_/ / / / / /_/ /  __/ /_/ / / / / / / / /
 __/ /\__,_/_/ /_/\__, /\___/\____/_/ /_/_/ /_/_/
/___/            /____/
            ]],
		},
	},
})

-- Send messages to the system notification centre while the terminal is unfocused
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

require("noice").setup({
	routes = {
		{
			filter = {
				cond = function()
					return not focused
				end,
			},
			view = "notify_send",
			opts = { stop = false },
		},
		{
			filter = { event = "notify", find = "No information available" },
			opts = { skip = true },
		},
	},
	commands = {
		all = {
			-- options for the message history that you get with `:Noice`
			view = "split",
			opts = { enter = true, format = "details" },
			filter = {},
		},
	},
	-- override markdown rendering so that blink.cmp and other plugins use Treesitter
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = true, -- add a border to hover docs and signature help
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(event)
		vim.schedule(function()
			require("noice.text.markdown").keys(event.buf)
		end)
	end,
})

require("bufferline").setup({
	options = {
		mode = "tabs",
		show_buffer_close_icons = false,
		show_close_icon = false,
	},
})
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev tab" })

require("lualine").setup({
	sections = {
		lualine_c = {
			{
				"filename",
				path = 1,
				symbols = { modified = "", readonly = " 󰌾 " },
			},
		},
	},
})

require("zen-mode").setup({
	plugins = {
		gitsigns = true,
		kitty = { enabled = false, font = "+2" },
	},
})
vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Zen Mode" })

local neoscroll = require("neoscroll")
neoscroll.setup({
	mappings = {},
	hide_cursor = false, -- keep the cursor visible so smear-cursor draws motion consistently
	stop_eof = true,
	respect_scrolloff = false,
	cursor_scrolls_alone = true,
	easing_function = "quadratic",
})

-- stylua: ignore
local scroll_keys = {
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
for key, func in pairs(scroll_keys) do
	vim.keymap.set({ "n", "v", "x" }, key, func)
end

require("smear_cursor").setup({
	distance_stop_animating = 0.8,
	stiffness = 0.5,
	trailing_stiffness = 0.5,
	matrix_pixel_threshold = 0.5,
})

-- breadcrumbs: show the "file > class > function" path in the winbar
require("dropbar").setup({})
vim.keymap.set("n", "<leader>;", function()
	require("dropbar.api").pick()
end, { desc = "Breadcrumbs pick" })
