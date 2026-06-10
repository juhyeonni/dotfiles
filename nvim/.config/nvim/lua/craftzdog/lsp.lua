local M = {}

function M.toggleInlayHints()
	-- nvim 0.10+ 시그니처: enable(enable: boolean, filter?: {bufnr})
	local filter = { bufnr = 0 }
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
end

return M
