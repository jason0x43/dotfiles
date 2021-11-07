local M = {}

M.config = {
  filetypes = { 'json', 'jsonc' },

  on_attach = function(client)
    -- disable formatting for JSON; we'll use prettier through null-ls instead
    client.resolved_capabilities.document_formatting = false
  end
}

local schemastore = require('req')('schemastore')
if schemastore then
  M.config.settings = {
    json = {
      schemas = schemastore.json.schemas()
    }
  }
end

return M
