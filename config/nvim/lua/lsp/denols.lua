local M = {}

local lsp_find_root = require('lspconfig.util').root_pattern(
  'package.json',
  'deps.ts',
  'mod.ts',
  '.git'
)

M.config = {
  root_dir = function(filename)
    local dir = lsp_find_root(filename)
    if dir ~= nil then
      return dir
    end

    -- return the files path as the default root
    return vim.fn.fnamemodify(filename, ':h')
  end,

  should_attach = function()
    return vim.fn.findfile('tsconfig.json', '.;') == ''
      and vim.fn.findfile('jsconfig.json', '.;') == ''
  end,
}

return M
