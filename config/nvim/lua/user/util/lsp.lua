local lsp_util = require('lspconfig').util

---@class(partial) LspConfig: lspconfig.Config
---@field root_dir? string | (fun(filename: string, bufnr: number): string?)

---@class(exact) UserLspConfig
---@field should_start? boolean | (fun(file: string): boolean)
---@field config? LspConfig

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

---@return UserLspConfig
M.make_user_config = function()
  return { config = {} }
end

return M
