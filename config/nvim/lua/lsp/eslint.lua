local denols = require('lsp.denols')

local M = {}

M.config = {
  -- enable single file support so lspconfig doesn't print a "root dir not
  -- detected" message every time a js/ts file is opened.
  single_file_support = true,

  should_attach = function()
    return not denols.config.should_attach()
  end,
}

return M
