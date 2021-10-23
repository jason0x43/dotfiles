local M = {}

-- the VSCode CSS language server only provides completions when snippet support
-- is enabled
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

M.config = {
  capabilities = capabilities,
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

return M
