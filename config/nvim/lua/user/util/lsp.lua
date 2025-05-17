---@module 'lspconfig'

---@class(partial) PartialLspConfig: lspconfig.Config
---@field root_dir? string | (fun(filename: string, bufnr: number): string?)

---@class(exact) UserLspConfig
---@field should_start? boolean | (fun(file: string): boolean)
---@field config? PartialLspConfig

---@param buffer integer
---@param method string
local function lsp_method_supported(buffer, method)
  ---@type vim.lsp.Client[]
  local active_clients = vim.lsp.get_clients({ bufnr = buffer })

  for _, active_client in pairs(active_clients) do
    if active_client:supports_method(method) then
      return true
    end
  end
end

local M = {}

---@return UserLspConfig
M.make_user_config = function()
  return { config = {} }
end

---Organize imports for the given buffer.
---@param buffer integer
M.organize_imports = function(buffer)
  if not lsp_method_supported(buffer, 'textDocument/codeAction') then
    return
  end

  vim.lsp.buf.code_action({
    context = {
      diagnostics = {},
      only = { 'source.organizeImports' },
    },
    apply = true,
  })
end

return M
