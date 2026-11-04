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
