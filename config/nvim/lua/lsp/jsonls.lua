local M = {}

M.config = {
  filetypes = { 'json', 'jsonc' },

  on_attach = function(client)
    -- disable formatting for JSON; we'll use prettier through null-ls instead
    client.resolved_capabilities.document_formatting = false
  end
}

return M
