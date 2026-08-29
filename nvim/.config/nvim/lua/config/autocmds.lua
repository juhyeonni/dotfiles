-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
-- markdown is excluded: render-markdown.nvim manages conceallevel per window
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- wrap is off for markdown so render-markdown's fixed-width tables do not break on line wrap.
-- Long prose lines scroll horizontally instead. Per-buffer toggle: <leader>uw
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = false
	end,
})
