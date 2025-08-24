---@type vim.lsp.Config
local config = {
  on_attach = function(client)
    -- disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
  end,
}

vim.lsp.config('ruff', config)
