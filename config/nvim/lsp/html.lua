local C = require('user.util.lsp').make_config()

C.filetypes = { 'html', 'svg', 'xml' }
C.init_options = {
  -- disable formatting for html; we'll use prettier instead
  provideFormatter = false,
}

return C
