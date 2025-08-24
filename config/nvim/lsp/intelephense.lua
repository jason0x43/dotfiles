---@type vim.lsp.Config
local config = {
  init_options = {
    globalStoragePath = vim.uv.os_homedir() .. '/.local/share/intelephense',
    licenceKey = os.getenv('INTELEPHENSE_KEY'),
  },
}

vim.lsp.config('intelephense', config)
