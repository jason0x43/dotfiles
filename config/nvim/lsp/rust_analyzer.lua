---@type vim.lsp.Config
local config = {
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        enable = true,
      },
      diagnostics = {
        enable = true,
      },
    },
  },
}

vim.lsp.config('rust_analyzer', config)
