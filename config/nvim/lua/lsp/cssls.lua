local M = {}

M.config = {
  settings = {
    css = {
      validate = true,
    },
    less = {
      validate = true,
    },
    scss = {
      validate = true,
    },
  },
}

local cmp = require('util').srequire('cmp')
if cmp then
  -- the VSCode CSS language server only provides completions when snippet
  -- support is enabled
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  M.config.capabilities = capabilities
end

return M
