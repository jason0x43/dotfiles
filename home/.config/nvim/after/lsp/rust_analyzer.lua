---@type vim.lsp.Config
return {
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
