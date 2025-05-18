local C = require('user.util.lsp').make_config()

C.settings = {
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
