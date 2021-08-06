local exports = {}

function exports.on_attach(client)
  -- disable formatting for html; we'll use prettier instead
  client.resolved_capabilities.document_formatting = false
end

-- the HTML language server doesn't have the completion capability enabled by
-- default, but it does support completions
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

exports.config = {
	capabilities = capabilities
}

return exports
