local lspconfig = require('lspconfig')
local lsp_util = require('user.lsp.util')

local M = {}

M.config = {
  autostart = false,
  root_dir = lspconfig.util.root_pattern('tsconfig.json', 'jsconfig.json'),
}

M.start = lsp_util.create_start('eslint')

lsp_util.create_autostart_autocmd('eslint', require('user.util').ts_types)

return M
