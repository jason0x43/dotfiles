local exports = {}

-- the VSCode CSS language server only provides completions when snippet support
-- is enabled
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

exports.config = {
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

return exports
