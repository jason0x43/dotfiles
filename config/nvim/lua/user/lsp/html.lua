local M = {}

M.config = {
  filetypes = { 'html', 'svg', 'xml' },

  on_attach = function(client)
    -- disable formatting for html; we'll use prettier instead
    client.resolved_capabilities.document_formatting = false
  end,
}

return M
