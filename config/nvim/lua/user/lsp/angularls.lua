local C = require('user.util.lsp').make_user_config()

C.config.on_attach = function(_, bufnr)
  -- disable renaming from ts_ls
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'vdtls' })
  for _, clt in ipairs(clients) do
    clt.server_capabilities.renameProvider = false
  end
end

return C
