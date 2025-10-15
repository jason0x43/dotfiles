---@type vim.lsp.Config
return {
  bundle_path = '/Users/jason/.local/share/nvim/mason/packages/powershell-editor-services',
  settings = {
    powershell = {
      codeFormatting = {
        Preset = 'OTBS',
      },
    },
  },
  init_options = {
    enableProfileLoading = false,
  },
}
