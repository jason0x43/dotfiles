local C = require('user.util.lsp').make_config()

C.init_options = {
  globalStoragePath = vim.uv.os_homedir() .. '/.local/share/intelephense',
  licenceKey = os.getenv('INTELEPHENSE_KEY'),
}

return C
