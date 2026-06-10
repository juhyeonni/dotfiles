return {
	-- 4. 스크롤 고정 헤더: 긴 함수/블록 안에서 스크롤해도 상단에 헤더 줄 고정
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufReadPost",
		opts = {
			max_lines = 3, -- 최대 3줄까지만 고정 표시
			multiline_threshold = 1,
			trim_scope = "outer",
			separator = "─", -- 고정 영역 아래 구분선
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

	-- 3. breadcrumbs: 창 상단(winbar)에 "파일 > 클래스 > 함수" 경로 표시
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
