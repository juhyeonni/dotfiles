return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		filesystem = {
			filtered_items = {
				visible = true, -- 기본적으로 숨김 파일 보이기
				hide_dotfiles = false, -- 점(.) 파일 표시
				hide_gitignored = false, -- Git에서 무시된 파일 표시
			},
		},
	},
}
