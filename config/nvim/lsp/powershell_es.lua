local C = require('user.util.lsp').make_config()

vim.lsp.config('powershell_es', {
  bundle_path = '/Users/jason/.local/share/nvim/mason/packages/powershell-editor-services',
})

C.settings = {
  powershell = {
    codeFormatting = {
      Preset = "OTBS"
    },
  },
}

C.init_options = {
  enableProfileLoading = false,
}

return C
