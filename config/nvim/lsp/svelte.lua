local C = require('user.util.lsp').make_config()

C.capabilities = {
  workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    },
  },
}

return C
