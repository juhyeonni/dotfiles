-- wrap is off for markdown so render-markdown's fixed-width tables do not break on line wrap.
-- Long prose lines scroll horizontally instead. Per-buffer toggle: :setlocal wrap!
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = false
	end,
})
