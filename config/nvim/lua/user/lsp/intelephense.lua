local lsp_util = require('user.lsp.util')

local M = {}

M.config = {
  init_options = {
    globalStoragePath = os.getenv('HOME') .. '/.local/share/intelephense'
  },

  on_attach = function(client)
    if vim.fn.executable('prettier') then
      -- disable formatting; we'll use prettier instead
      lsp_util.disable_formatting(client)
    end
  end,

}

return M
