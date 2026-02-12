return {
	-- {
	-- 	"craftzdog/solarized-osaka.nvim",
	-- 	lazy = true,
	-- 	priority = 1000,
	-- 	opts = function()
	-- 		return {
	-- 			transparent = true,
	-- 		}
	-- 	end,
	-- },
	--
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
		},
	},
}
