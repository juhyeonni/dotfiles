local keymap = vim.keymap

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"-1p')
keymap.set("n", "<Leader>P", '"-1P')
keymap.set("v", "<Leader>p", '"-1p')

-- <C-a> collides with the herdr prefix, so select-all lives on <leader>A
keymap.set("n", "<leader>A", "gg<S-v>G", { desc = "Select all" })

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

keymap.set("n", "<leader>j", vim.lsp.buf.hover, { desc = "Hover" })
keymap.set("n", "<leader>Q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Pass Shift+Enter as CSI u sequence to terminal processes (e.g. Claude Code)
keymap.set("t", "<S-CR>", "\x1b[13;2u", { noremap = true })
