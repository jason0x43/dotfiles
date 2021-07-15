local LanguageServers = require('lualine.component'):new()

LanguageServers.update_status = function(self)
  local clients = vim.lsp.buf_get_clients()
  local client_names = {}

  for _, client in pairs(clients) do
    table.insert(client_names, client.name)
  end

  if not vim.tbl_isempty(client_names) then
    self.options.icon = ''
    return table.concat(client_names, ', ')
  end

  return ''
end

return LanguageServers
