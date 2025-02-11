local C = require('user.util.lsp').make_user_config()

C.config.settings = {
  ['rust-analyzer'] = {
    checkOnSave = {
      enable = false,
    },
    diagnostics = {
      enable = false,
    },
  },
}

return C
