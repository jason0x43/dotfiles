local LanguageServers = require('lualine.component'):extend()

function LanguageServers:update_status()
  local clients = vim.lsp.buf_get_clients()
  local client_names = {}

  for _, client in pairs(clients) do
    table.insert(client_names, client.name)
  end

  if not vim.tbl_isempty(client_names) then
    self.options.icon = ''
    local name_list = table.concat(client_names, ',')
    local winwidth = vim.fn.winwidth(0)
    if #name_list > math.floor(winwidth * 0.15) then
      client_names = vim.tbl_map(function(item)
        return item:sub(1, 2)
      end, client_names)
      name_list = table.concat(client_names, ',')
    end
    return name_list
  end

  return ''
end

return LanguageServers
