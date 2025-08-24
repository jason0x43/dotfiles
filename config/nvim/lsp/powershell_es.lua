---@type vim.lsp.Config
local config = {
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

vim.lsp.config('powershell_es', config)
