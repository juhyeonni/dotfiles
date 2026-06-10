return {
	-- markview와 render-markdown은 둘 다 in-buffer 렌더라 동시에 켜면 충돌한다.
	-- markview를 쓰는 동안 render-markdown은 끔. (되돌리려면 이 파일을 지우거나
	-- 아래 enabled=false를 지우면 render-markdown 설정이 다시 살아난다.)
	{ "MeanderingProgrammer/render-markdown.nvim", enabled = false },

	{
		"OXY2DEV/markview.nvim",
		ft = { "markdown", "codecompanion" },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			preview = {
				icon_provider = "devicons",
				-- hybrid 모드: 커서가 있는 줄만 raw 마크업, 나머지는 전부 렌더
				hybrid_modes = { "n" },
			},
		},
	},
}
