---@module 'lspconfig'

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

---@return vim.lsp.Config
M.make_config = function()
  return {}
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

---Return the project root if this is a deno project
---@param bufnr integer
---@return string | nil
M.get_deno_root = function(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(file, { 'deno.json', 'deno.jsonc' })
  if root then
    return root
  end

  local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
  if first_line:find('#!/usr/bin/env %-S deno') ~= nil then
    return vim.fn.getcwd()
  end

  return nil
end

return M
