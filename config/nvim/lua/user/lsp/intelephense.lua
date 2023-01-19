local lsp_util = require('user.lsp.util')

local licenseKey = os.getenv('INTELEPHENSE_KEY')

local M = {}

M.config = {
  init_options = {
    globalStoragePath = os.getenv('HOME') .. '/.local/share/intelephense',
    licenceKey = licenseKey,
  },

  on_attach = function(client)
    if vim.fn.executable('prettier') then
      -- disable formatting; we'll use prettier instead
      lsp_util.disable_formatting(client)
    end
  end,
}

return M
