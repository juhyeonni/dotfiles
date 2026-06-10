local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"-1p')
keymap.set("n", "<Leader>P", '"-1P')
keymap.set("v", "<Leader>p", '"-1p')
-- 참고: blackhole change/delete (<leader>c/x)는 LazyVim의 code/diagnostics 그룹
-- (<leader>ca 등)을 가려 제거함. 필요하면 표준 "_c / "_dd 를 직접 사용.

-- dw는 표준 동작(커서→다음 단어 삭제) 유지 — 이전의 vb"_d 오버라이드 제거

-- Select all (<C-a>는 tmux prefix·dial.nvim increment와 충돌하여 <leader>A로 이동)
keymap.set("n", "<leader>A", "gg<S-v>G", { desc = "Select all" })

-- New tab (<Tab>/<S-Tab>은 bufferline이 담당하므로 여기선 te만)
keymap.set("n", "te", ":tabedit", { desc = "New Tab" })

-- Split window (flash의 s 점프와 충돌하던 ss/sv 제거 — LazyVim 기본 <leader>- / <leader>| 사용)

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Diagnostic (use ]d / [d from LazyVim defaults)

keymap.set("n", "<leader>j", vim.lsp.buf.hover)
-- <leader>q는 LazyVim quit 그룹이므로 진단 loclist는 <leader>Q로 이동
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

