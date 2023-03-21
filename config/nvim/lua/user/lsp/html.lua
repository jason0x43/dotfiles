local M = {}

M.config = {
  filetypes = { 'html', 'svg', 'xml' },

  init_options = {
		-- disable formatting for html; we'll use prettier instead
    provideFormatter = false,
  },
}

return M
