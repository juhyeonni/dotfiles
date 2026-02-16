local M = {}

local function get_visual_selection()
	local start_pos = vim.api.nvim_buf_get_mark(0, "<")
	local end_pos = vim.api.nvim_buf_get_mark(0, ">")
	local start_row, start_col = start_pos[1], start_pos[2]
	local end_row, end_col = end_pos[1], end_pos[2]

	if start_row == 0 or end_row == 0 then
		return nil
	end

	if start_row > end_row or (start_row == end_row and start_col > end_col) then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end

	local lines = vim.api.nvim_buf_get_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, {})
	if not lines or #lines == 0 then
		return nil
	end

	local text = table.concat(lines, "\n")
	if text == "" then
		return nil
	end

	return text
end

local function open_claude_code_window()
	if vim.fn.exists(":ClaudeCode") == 2 then
		vim.cmd("ClaudeCode")
		return true
	end

	local ok, claude_code = pcall(require, "claude-code")
	if not ok then
		return false
	end

	if type(claude_code.toggle) == "function" then
		claude_code.toggle()
		return true
	end

	if type(claude_code.open) == "function" then
		claude_code.open()
		return true
	end

	return false
end

local function find_claude_terminal_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype == "terminal" then
			local name = vim.api.nvim_buf_get_name(buf):lower()
			local ft = vim.bo[buf].filetype:lower()
			if name:find("claude") or ft:find("claude") then
				return win
			end
		end
	end
	return nil
end

local function find_claude_terminal_job_id()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local is_terminal = vim.bo[buf].buftype == "terminal"
			if is_terminal then
				local name = vim.api.nvim_buf_get_name(buf):lower()
				local filetype = vim.bo[buf].filetype:lower()
				if name:find("claude") or filetype:find("claude") then
					local ok, job_id = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
					if ok and job_id then
						return job_id
					end
				end
			end
		end
	end

	return nil
end

local function ask_claude(selected_text)
	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		file_path = "[No Name]"
	end

	-- Focus existing Claude Code window, or open a new one
	local claude_win = find_claude_terminal_win()
	if claude_win then
		vim.api.nvim_set_current_win(claude_win)
	else
		if not open_claude_code_window() then
			vim.notify("Failed to open claude-code.nvim window", vim.log.levels.ERROR)
			return
		end
	end

	vim.defer_fn(function()
		local job_id = find_claude_terminal_job_id()
		if not job_id then
			vim.notify("Could not find Claude Code terminal", vim.log.levels.ERROR)
			return
		end

		if selected_text and selected_text ~= "" then
			-- Use Shift+Enter (CSI u sequence) for newlines to avoid auto-submit
			local se = "\x1b[13;2u"
			local code_escaped = selected_text:gsub("\n", se)
			local input = file_path .. ":" .. se .. "```" .. se .. code_escaped .. se .. "```" .. se
			vim.api.nvim_chan_send(job_id, input)
		end

		-- Enter terminal insert mode so user can type directly
		vim.cmd("startinsert")
	end, 200)
end

local function get_code_actions(mode)
	local params
	if mode == "v" or mode == "V" or mode == "\22" then
		params = vim.lsp.util.make_given_range_params()
	else
		params = vim.lsp.util.make_range_params()
	end

	params.context = {
		diagnostics = vim.diagnostic.get(0),
	}

	local responses = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000) or {}
	local actions = {}

	for client_id, response in pairs(responses) do
		for _, action in ipairs(response.result or {}) do
			table.insert(actions, {
				action = action,
				client_id = client_id,
				title = action.title,
			})
		end
	end

	return actions
end

local function apply_action(item)
	local action = item.action
	local client = vim.lsp.get_client_by_id(item.client_id)

	if action.edit then
		local encoding = client and client.offset_encoding or "utf-16"
		vim.lsp.util.apply_workspace_edit(action.edit, encoding)
	end

	if action.command then
		if type(action.command) == "table" then
			vim.lsp.buf.execute_command(action.command)
		else
			vim.lsp.buf.execute_command(action)
		end
	end
end

function M.code_action_with_claude()
	local mode = vim.fn.mode()
	local selected_text = nil
	if mode == "v" or mode == "V" or mode == "\22" then
		selected_text = get_visual_selection()
	end

	local lsp_actions = get_code_actions(mode)
	local items = {
		{
			title = "Ask Claude Code about selection/file",
			kind = "claude-code",
			handler = function()
				ask_claude(selected_text)
			end,
		},
	}

	for _, item in ipairs(lsp_actions) do
		table.insert(items, {
			title = item.title,
			kind = "lsp",
			action_item = item,
		})
	end

	vim.ui.select(items, {
		prompt = "Code Actions",
		format_item = function(entry)
			if entry.kind == "claude-code" then
				return "🤖 " .. entry.title
			end
			return "󰌵 " .. entry.title
		end,
	}, function(choice)
		if not choice then
			return
		end

		if choice.kind == "claude-code" then
			choice.handler()
			return
		end

		apply_action(choice.action_item)
	end)
end

return M
