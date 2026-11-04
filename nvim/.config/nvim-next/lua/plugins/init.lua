local gh = require("utils").gh

-- The one place that lists every plugin. confirm = false: all sources are GitHub repos named
-- here, so the install prompt adds nothing and would block a fresh machine or a headless run.
vim.pack.add({
	{ src = gh("rebelot/kanagawa.nvim") },
	{ src = gh("neovim/nvim-lspconfig") },
	{ src = gh("mason-org/mason.nvim") },
}, { confirm = false })

-- Per-machine settings (git-ignored). Runs after vim.pack.add so it can add plugins, and
-- before the setup() calls so it can set variables they read.
if vim.uv.fs_stat(vim.fn.stdpath("config") .. "/lua/plugins/local.lua") then
	require("plugins.local")
end

require("plugins.ui")
require("plugins.lsp")
