---@type vim.lsp.Config
local config = {
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
}

vim.lsp.config('svelte', config)
