local C = require('user.util.lsp').make_user_config()

vim.lsp.config('powershell_es', {
  bundle_path = '/Users/jason/.local/share/nvim/mason/packages/powershell-editor-services',
})

C.config.settings = {
  powershell = {
    codeFormatting = {
      Preset = "OTBS"
    },
  },
}

C.config.init_options = {
  enableProfileLoading = false,
}

return C
