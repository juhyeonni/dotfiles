return {
	-- Disable LazyVim default themes (kanagawa only)
	{ "catppuccin/nvim", enabled = false },
	{ "folke/tokyonight.nvim", enabled = false },
	{ "craftzdog/solarized-osaka.nvim", enabled = false },

	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		opts = {
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
			-- background이 theme보다 우선하므로 같이 지정해야 함
			background = { dark = "dragon", light = "lotus" },
		},
	},
}
