local M = {}

-- Expects '< '> marks to be set (call after exiting visual mode)
local function get_visual_selection()
	local sp = vim.api.nvim_buf_get_mark(0, "<")
	local ep = vim.api.nvim_buf_get_mark(0, ">")
	local srow, scol = sp[1], sp[2]
	local erow, ecol = ep[1], ep[2]

	if srow == 0 or erow == 0 then
		return nil
	end

	if srow > erow or (srow == erow and scol > ecol) then
		srow, erow = erow, srow
		scol, ecol = ecol, scol
	end

	-- nvim_buf_get_text: 0-indexed rows/cols, end_col exclusive
	local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol, erow - 1, ecol + 1, {})
	if not lines or #lines == 0 then
		return nil
	end

	local text = table.concat(lines, "\n")
	if text == "" then
		return nil
	end

	return text, srow, erow
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

local function ask_claude(selected_text, start_line, end_line)
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

		-- Enter terminal insert mode first
		vim.cmd("startinsert")

		if selected_text and selected_text ~= "" then
			local range = ""
			if start_line and end_line then
				range = ":" .. start_line .. "-" .. end_line
			end
			local content = file_path .. range .. ":\n```\n" .. selected_text .. "\n```\n"
			vim.schedule(function()
				vim.api.nvim_paste(content, true, -1)
			end)
		end
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

function M.code_action_with_claude(from_visual)
	local selected_text = nil

	local start_line, end_line
	if from_visual then
		-- '< '> marks are already set by :<C-u> in the keymap
		selected_text, start_line, end_line = get_visual_selection()
	end

	local lsp_actions = get_code_actions(from_visual and "v" or "n")
	local items = {
		{
			title = "Ask Claude Code about selection/file",
			kind = "claude-code",
			handler = function()
				ask_claude(selected_text, start_line, end_line)
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
