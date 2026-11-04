-- The main branch of nvim-treesitter builds parsers with the tree-sitter CLI, so install only when
-- it exists. Highlighting starts for any filetype that has a parser.
if vim.fn.executable("tree-sitter") == 1 then
	require("nvim-treesitter").install({
		"astro",
		"bash",
		"cmake",
		"cpp",
		"css",
		"fish",
		"gitignore",
		"go",
		"graphql",
		"html",
		"http",
		"java",
		"javascript",
		"json",
		"lua",
		"markdown",
		"markdown_inline",
		"php",
		"query",
		"rust",
		"scss",
		"sql",
		"svelte",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"yaml",
	})
end

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		pcall(vim.treesitter.start, ev.buf)
	end,
})

-- Sticky scroll header: pins the header line at the top while scrolling inside a long function/block
require("treesitter-context").setup({
	max_lines = 3, -- pin at most 3 lines
	multiline_threshold = 1,
	trim_scope = "outer",
	separator = "─", -- divider under the pinned region
})
vim.keymap.set("n", "<leader>ut", function()
	require("treesitter-context").toggle()
end, { desc = "Toggle Treesitter Context" })

require("nvim-ts-autotag").setup({})
