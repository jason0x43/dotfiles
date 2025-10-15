---@type vim.lsp.Config
return {
  init_options = {
    globalStoragePath = vim.uv.os_homedir() .. '/.local/share/intelephense',
    licenceKey = os.getenv('INTELEPHENSE_KEY'),
  },
}
