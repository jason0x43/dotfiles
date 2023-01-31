local lsp_util = require('user.lsp.util')
local M = {}

M.config = {
  filetypes = { 'json', 'jsonc' },

  on_attach = function(client)
    -- disable formatting for JSON; we'll use prettier through null-ls instead
    lsp_util.disable_formatting(client)
  end,
}

local schemastore = require('schemastore')
if schemastore then
  M.config.settings = {
    json = {
      schemas = schemastore.json.schemas(),
      validate = { enable = true },
    },
  }
end

return M
