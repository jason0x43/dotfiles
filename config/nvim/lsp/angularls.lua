---@type vim.lsp.Config
local config = {
  on_attach = function(_, bufnr)
    -- disable renaming from ts_ls
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'vdtls' })
    for _, clt in ipairs(clients) do
      clt.server_capabilities.renameProvider = false
    end
  end,
}

vim.lsp.config('angularls', config)
