local M = {}

local function get_visual_selection()
	local bufnr = 0
	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
		return nil
	end
	local srow, scol = unpack(vim.api.nvim_buf_get_mark(bufnr, "<"))
	local erow, ecol = unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))
	if srow > erow or (srow == erow and scol > ecol) then
		srow, erow = erow, srow
		scol, ecol = ecol, scol
	end
	local lines = vim.api.nvim_buf_get_text(bufnr, srow - 1, scol, erow - 1, ecol + 1, {})
	return table.concat(lines, "\n")
end

local function get_buffer_text()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	return table.concat(lines, "\n")
end

local function get_diagnostics_summary()
	local diags = vim.diagnostic.get(0)
	if #diags == 0 then
		return ""
	end
	local out = {}
	for _, d in ipairs(diags) do
		table.insert(
			out,
			string.format(
				"[%s] L%d:%d %s",
				(
					d.severity == vim.diagnostic.severity.ERROR and "E"
					or d.severity == vim.diagnostic.severity.WARN and "W"
					or d.severity == vim.diagnostic.severity.INFO and "I"
					or "H"
				),
				(d.lnum or 0) + 1,
				(d.col or 0) + 1,
				d.message:gsub("\n", " ")
			)
		)
	end
	return table.concat(out, "\n")
end

function M.ask_claude(opts)
	opts = opts or {}
	local selection = get_visual_selection()
	local code = selection or get_buffer_text()
	local diag = get_diagnostics_summary()

	local question = opts.question or vim.fn.input("ask: ")
	if question == nil or question == "" then
		return
	end

	local prompt = question
	if diag ~= "" then
		prompt = prompt .. "\n\n[Neovim diagnostics]\n" .. diag
	end

	vim.system({ "claude", "-p", prompt }, { stdin = code, text = true }, function(res)
		vim.schedule(function()
			if res.code ~= 0 then
				vim.notify("failed to run claude-code:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
				return
			end

			vim.cmd("vnew")
			vim.bo.buftype = "nofile"
			vim.bo.bufhidden = "wipe"
			vim.bo.swapfile = false
			vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(res.stdout or "", "\n", { plain = true }))
			vim.bo.filetype = "markdown"
		end)
	end)
end

return M
