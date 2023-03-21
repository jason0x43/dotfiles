local licenseKey = os.getenv('INTELEPHENSE_KEY')

local M = {}

M.config = {
  init_options = {
    globalStoragePath = os.getenv('HOME') .. '/.local/share/intelephense',
    licenceKey = licenseKey,
  },
}

return M
