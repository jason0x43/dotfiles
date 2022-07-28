local lsp_util = require('user.lsp.util')
local M = {}

M.config = {
  filetypes = { 'html', 'svg', 'xml' },

  on_attach = function(client)
    -- disable formatting for html; we'll use prettier instead
    lsp_util.disable_formatting(client)
  end,
}

return M
