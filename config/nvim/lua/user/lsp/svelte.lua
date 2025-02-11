local C = require('user.util.lsp').make_user_config()

C.config.capabilities = {
  workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    },
  },
}

return C
