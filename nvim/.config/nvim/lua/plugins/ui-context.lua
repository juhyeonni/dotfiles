return {
	-- 4. Sticky scroll header: pins the header line at the top while scrolling inside a long function/block
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufReadPost",
		opts = {
			max_lines = 3, -- pin at most 3 lines
			multiline_threshold = 1,
			trim_scope = "outer",
			separator = "─", -- divider under the pinned region
		},
		keys = {
			{
				"<leader>ut",
				function()
					require("treesitter-context").toggle()
				end,
				desc = "Toggle Treesitter Context",
			},
		},
	},

	-- 3. breadcrumbs: show the "file > class > function" path in the winbar
	{
		"Bekaboo/dropbar.nvim",
		event = "BufReadPost",
		opts = {},
		keys = {
			{
				"<leader>;",
				function()
					require("dropbar.api").pick()
				end,
				desc = "Breadcrumbs pick",
			},
		},
	},
}
