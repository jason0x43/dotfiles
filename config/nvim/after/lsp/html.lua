---@type vim.lsp.Config
return {
  filetypes = { 'html', 'svg', 'xml' },
  init_options = {
    -- disable formatting for html; we'll use prettier instead
    provideFormatter = false,
  },
}
