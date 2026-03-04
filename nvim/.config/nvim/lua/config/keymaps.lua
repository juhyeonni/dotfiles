local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"-1p')
keymap.set("n", "<Leader>P", '"-1P')
keymap.set("v", "<Leader>p", '"-1p')
keymap.set("n", "<Leader>c", '"_c')
keymap.set("n", "<Leader>C", '"_C')
keymap.set("v", "<Leader>c", '"_c')
keymap.set("v", "<Leader>C", '"_C')
keymap.set({ "n", "v" }, "<Leader>x", '"_d', { desc = "Delete without register" })
keymap.set({ "n", "v" }, "<Leader>X", '"_D', { desc = "Delete to EOL without register" })

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- New tab
keymap.set("n", "te", ":tabedit", { desc = "New Tab" })
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Diagnostic (use ]d / [d from LazyVim defaults)

keymap.set("n", "<leader>j", vim.lsp.buf.hover)
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

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

