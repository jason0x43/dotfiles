local M = {}

M.config = { filetypes = { 'json', 'jsonc' } }

function M.on_attach(client)
  -- disable formatting for JSON; we'll use prettier through null-ls instead
  client.resolved_capabilities.document_formatting = false
end

return M
