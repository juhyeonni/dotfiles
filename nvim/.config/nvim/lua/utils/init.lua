local M = {}

function M.gh(repo)
	return "https://github.com/" .. repo
end

function M.toggle_inlay_hints()
	local filter = { bufnr = 0 }
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
end

return M
