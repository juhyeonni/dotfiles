-- mason.setup() puts its bin directory on PATH, which is how nvim finds the servers it installs.
require("mason").setup()

-- Per-server settings live in after/lsp/<name>.lua, which merges over nvim-lspconfig's defaults.
vim.lsp.enable({ "lua_ls" })
