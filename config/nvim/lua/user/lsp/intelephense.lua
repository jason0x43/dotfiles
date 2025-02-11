local C = require('user.util.lsp').make_user_config()

C.config.init_options = {
  globalStoragePath = os.getenv('HOME') .. '/.local/share/intelephense',
  licenceKey = os.getenv('INTELEPHENSE_KEY'),
}

return C
