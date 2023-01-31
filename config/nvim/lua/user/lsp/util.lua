local M = {}

function M.disable_formatting(client)
  client.server_capabilities.documentFormattingProvider = false
end

return M
