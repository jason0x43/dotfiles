local M = {}

M.config = {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'hs', 'vim', 'packer_plugins' },
        -- This seems to always generate false positives
        disable = { 'different-requires' },
      },
    },
  },
}

if vim.fn.executable('stylua') ~= 0 then
  M.config.on_attach = function(client)
    -- disable formatting; we'll use stylua instead
    client.resolved_capabilities.document_formatting = false
  end
end

return M

