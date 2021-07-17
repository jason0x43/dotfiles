local exports = {}

function exports.setup()
  -- sourcekit isn't handled by lspinstall
  require('lspconfig').sourcekit.setup({
    -- use the cpp lsp for C/CPP
    filetypes = { 'swift' },
    on_attach = require('lsp').on_attach,
  })
end

return exports
