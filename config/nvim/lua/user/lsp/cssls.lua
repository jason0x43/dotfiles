local C = require('user.util.lsp').make_user_config()

C.config.settings = {
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
