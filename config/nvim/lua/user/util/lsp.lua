---@class(partial) LspConfig: lspconfig.Config
---@field root_dir? string | (fun(filename: string, bufnr: number): string?)

---@class(exact) UserLspConfig
---@field should_start? boolean | (fun(file: string): boolean)
---@field config? LspConfig

local M = {}

---@return UserLspConfig
M.make_user_config = function()
  return { config = {} }
end

return M
