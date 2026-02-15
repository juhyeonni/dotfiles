local M = {}

local function get_visual_selection()
	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
		return nil
	end

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
	return table.concat(lines, "\n")
end

local function build_prompt(question)
	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		file_path = "[No Name]"
	end

	local selection = get_visual_selection()
	if selection and selection ~= "" then
		return string.format(
			"Question about selected code in %s:\n\n%s\n\n```\n%s\n```",
			file_path,
			question,
			selection
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

local function ask_claude()
	vim.ui.input({ prompt = "Ask Claude Code: " }, function(question)
		if not question or question == "" then
			return
		end

		local prompt = build_prompt(question)
		local command = string.format("printf %%s %s | claude-code", vim.fn.shellescape(prompt))

		vim.cmd("botright vsplit")
		vim.cmd("terminal " .. command)
		vim.cmd("startinsert")
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
	local lsp_actions = get_code_actions(mode)
	local items = {
		{
			title = "Ask Claude Code about selection/file",
			kind = "claude-code",
			handler = ask_claude,
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
