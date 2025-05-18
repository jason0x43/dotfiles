local C = require('user.util.lsp').make_config()

C.settings = {
  css = {
    validate = true,
    lint = {
      unknownAtRules = 'ignore',
    },
  },
  less = {
    validate = true,
  },
  scss = {
    validate = true,
  },
}

return C
