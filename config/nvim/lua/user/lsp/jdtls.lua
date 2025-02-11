local C = require('user.util.lsp').make_user_config()

C.config.cmd_env = {
  WORKSPACE = vim.fn.getenv('HOME') .. '/.cache/workspace',
}

return C
