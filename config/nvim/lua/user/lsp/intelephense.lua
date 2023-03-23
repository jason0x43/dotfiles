local licenseKey = os.getenv('INTELEPHENSE_KEY')

return {
  config = {
    init_options = {
      globalStoragePath = os.getenv('HOME') .. '/.local/share/intelephense',
      licenceKey = licenseKey,
    },
  },
}
