local lsp_util = require('lspconfig').util

local M = {}

M.get_available_server_names = function(filetype)
  if filetype == nil then
    filetype = vim.bo.filetype
  end

  local others = lsp_util.get_other_matching_providers(filetype)
  return vim.tbl_map(function(val)
    return val.name
  end, others)
end

M.server_is_available = function(server, filetype)
  local servers = M.get_available_server_names(filetype)
  return vim.tbl_contains(servers, server)
end

return M
