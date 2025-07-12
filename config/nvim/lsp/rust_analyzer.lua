local C = require('user.util.lsp').make_config()

C.settings = {
  ['rust-analyzer'] = {
    checkOnSave = {
      enable = true,
    },
    diagnostics = {
      enable = true,
    },
  },
}

return C
