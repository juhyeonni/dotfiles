local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"-1p')
keymap.set("n", "<Leader>P", '"-1P')
keymap.set("v", "<Leader>p", '"-1p')
-- Note: the blackhole change/delete maps (<leader>c/x) shadowed LazyVim's code/diagnostics
-- groups (<leader>ca and friends), so they were removed. Use plain "_c / "_dd when needed.

-- dw keeps its standard behaviour (delete from cursor to next word) — the old vb"_d override is gone

-- Select all (<C-a> collided with the herdr prefix and dial.nvim increment, so it moved to <leader>A)
keymap.set("n", "<leader>A", "gg<S-v>G", { desc = "Select all" })

-- New tab (<Tab>/<S-Tab> belong to bufferline, so only te is defined here)
keymap.set("n", "te", ":tabedit", { desc = "New Tab" })

-- Split window (ss/sv removed; they collided with flash's s jump — use LazyVim's <leader>- / <leader>|)

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Diagnostic (use ]d / [d from LazyVim defaults)

keymap.set("n", "<leader>j", vim.lsp.buf.hover)
-- <leader>q is LazyVim's quit group, so the diagnostics loclist moved to <leader>Q
keymap.set("n", "<leader>Q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

keymap.set("n", "<leader>r", function()
	require("craftzdog.hsl").replaceHexWithHSL()
end)

keymap.set("n", "<leader>i", function()
	require("craftzdog.lsp").toggleInlayHints()
end)

-- Pass Shift+Enter as CSI u sequence to terminal processes (e.g. Claude Code)
keymap.set("t", "<S-CR>", "\x1b[13;2u", { noremap = true })

-- Ctrl+Space: show completion menu in insert mode (override <C-@> default)
keymap.set("i", "<C-@>", function()
	require("blink.cmp").show()
end, { desc = "Show completion menu" })

-- Toggle diagnostic display: single-line virtual text <-> multi-line (virtual_lines, nvim 0.11)
keymap.set("n", "<leader>uV", function()
	local enabled = vim.diagnostic.config().virtual_lines
	if enabled then
		vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
		vim.notify("Diagnostics: virtual text", vim.log.levels.INFO)
	else
		vim.diagnostic.config({ virtual_lines = true, virtual_text = false })
		vim.notify("Diagnostics: virtual lines", vim.log.levels.INFO)
	end
end, { desc = "Toggle diagnostic virtual lines" })

