---@type vim.lsp.Config
local config = {
  filetypes = { 'html', 'svg', 'xml' },
  init_options = {
    -- disable formatting for html; we'll use prettier instead
    provideFormatter = false,
  },
}

vim.lsp.config('html', config)
