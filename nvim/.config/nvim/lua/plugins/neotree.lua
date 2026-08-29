return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		filesystem = {
			filtered_items = {
				visible = true, -- show hidden files by default
				hide_dotfiles = false, -- show dotfiles
				hide_gitignored = false, -- show git-ignored files
			},
		},
	},
}
