local map = vim.keymap.set

-- Files: oil replaces netrw and the old file browser; hidden and git-ignored files stay visible
require("oil").setup({
	default_file_explorer = true,
	view_options = { show_hidden = true },
})
map("n", "<leader>fB", function()
	require("oil").open(vim.fn.expand("%:p:h"))
end, { desc = "Open file browser at the current buffer" })

-- Pickers (snacks)
map("n", ";f", function()
	Snacks.picker.files({ hidden = true })
end, { desc = "Files in cwd, respects .gitignore" })
map("n", ";r", function()
	Snacks.picker.grep({ hidden = true })
end, { desc = "Live grep in cwd" })
map("n", "\\\\", function()
	Snacks.picker.buffers()
end, { desc = "Open buffers" })
map("n", ";t", function()
	Snacks.picker.help()
end, { desc = "Help tags" })
map("n", ";;", function()
	Snacks.picker.resume()
end, { desc = "Resume the previous picker" })
map("n", ";e", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
map("n", ";s", function()
	Snacks.picker.treesitter()
end, { desc = "Treesitter symbols" })
map("n", "<leader>fP", function()
	Snacks.picker.files({ cwd = vim.fn.stdpath("data") .. "/site/pack/core/opt" })
end, { desc = "Find Plugin File" })

require("flash").setup({
	search = {
		forward = true,
		multi_window = false,
		wrap = false,
		incremental = true,
	},
})
map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })
map({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })

-- Surround: ys (add) / ds (delete) / cs (change) — wrap quotes, brackets, tags
require("nvim-surround").setup({})
require("mini.pairs").setup({})

-- Go forward/backward with square brackets
require("mini.bracketed").setup({
	file = { suffix = "" },
	window = { suffix = "" },
	quickfix = { suffix = "" },
	yank = { suffix = "" },
	treesitter = { suffix = "n" },
})

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
	highlighters = {
		hex_color = hipatterns.gen_highlighter.hex_color(),
		hsl_color = {
			pattern = "hsl%(%d+,? %d+%%?,? %d+%%?%)",
			group = function(_, match)
				local nh, ns, nl = match:match("hsl%((%d+),? (%d+)%%?,? (%d+)%%?%)")
				local h, s, l = tonumber(nh), tonumber(ns), tonumber(nl)
				local hex_color = require("utils.hsl").hslToHex(h, s, l)
				return hipatterns.compute_hex_color_group(hex_color, "bg")
			end,
		},
	},
})

-- Better increase/decrease
local augend = require("dial.augend")
require("dial.config").augends:register_group({
	default = {
		augend.integer.alias.decimal,
		augend.integer.alias.hex,
		augend.date.alias["%Y/%m/%d"],
		augend.constant.alias.bool,
		augend.semver.alias.semver,
		augend.constant.new({ elements = { "let", "const" } }),
	},
})
map("n", "<C-a>", function()
	return require("dial.map").inc_normal()
end, { expr = true, desc = "Increment" })
map("n", "<C-x>", function()
	return require("dial.map").dec_normal()
end, { expr = true, desc = "Decrement" })

require("refactoring").setup({})
map("v", "<leader>r", function()
	require("refactoring").select_refactor()
end, { noremap = true, silent = true })

require("outline").setup({ outline_window = { position = "right" } })
map("n", "<leader>cs", "<cmd>Outline<cr>", { desc = "Code Outline" })

-- Project-wide find/replace — bulk substitution UI across files
require("grug-far").setup({ headerMaxWidth = 80 })
map({ "n", "v" }, "<leader>sr", function()
	local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
	require("grug-far").open({
		transient = true,
		prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
	})
end, { desc = "Search and Replace (grug-far)" })

require("trouble").setup({})

require("todo-comments").setup({})
map("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next Todo Comment" })
map("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous Todo Comment" })

require("render-markdown").setup({
	-- Show raw markup only on the cursor line (easier editing); render everything else
	anti_conceal = { enabled = true },
	-- Indent body text by heading level so the hierarchy reads like a document
	indent = {
		enabled = true,
		per_level = 2, -- indent columns per level
		skip_level = 1, -- do not indent body under H1 (keep the top level flat)
		skip_heading = false,
	},
	heading = {
		sign = false,
		icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		width = "full", -- background bar across the whole heading line -> clearer section breaks
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
		preset = "round", -- rounded corner border
		-- 'padded': pads each cell to the column's max display width, so ragged source still aligns
		-- (CJK characters count as 2 columns via strdisplaywidth)
		cell = "padded",
		padding = 1,
		-- Show the direction on alignment rows (:---, ---:, :--:)
		alignment_indicator = "━",
		-- Draw top/bottom borders as virtual lines, so it does not rely on blank lines around the table
		border_virtual = true,
	},
	-- Highlight GitHub callouts like > [!NOTE] (using the default set)
	quote = { icon = "▎" },
})

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
