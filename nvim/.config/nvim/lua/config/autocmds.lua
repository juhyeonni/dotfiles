-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
-- markdown은 render-markdown.nvim이 창 단위로 conceallevel을 관리하므로 제외
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- render-markdown의 고정폭 표가 줄바꿈으로 깨지지 않도록 markdown은 wrap을 끔
-- 긴 산문 줄은 가로 스크롤로 처리. 버퍼별 토글: <leader>uw
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = false
	end,
})
