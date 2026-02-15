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

local function build_prompt(question, selected_text)
	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		file_path = "[No Name]"
	end

	if selected_text and selected_text ~= "" then
		return string.format(
			"Question about selected code in %s:\n\n%s\n\n```\n%s\n```",
			file_path,
			question,
			selected_text
		)
	end

	local file_contents = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	return string.format(
		"Question about file %s:\n\n%s\n\n```\n%s\n```",
		file_path,
		question,
		file_contents
	)
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
	vim.ui.input({ prompt = "Ask Claude Code: " }, function(question)
		if not question or question == "" then
			return
		end

		if not open_claude_code_window() then
			vim.notify("claude-code.nvim 창을 열 수 없습니다.", vim.log.levels.ERROR)
			return
		end

		local prompt = build_prompt(question, selected_text)
		local job_id = find_claude_terminal_job_id()
		if not job_id then
			vim.notify("Claude Code 터미널을 찾지 못했습니다.", vim.log.levels.ERROR)
			return
		end

		vim.api.nvim_chan_send(job_id, prompt .. "\n")
	end)
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
