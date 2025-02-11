local C = require('user.util.lsp').make_user_config()

C.config.filetypes = { 'html', 'svg', 'xml' }
C.config.init_options = {
  -- disable formatting for html; we'll use prettier instead
  provideFormatter = false,
}

return C
