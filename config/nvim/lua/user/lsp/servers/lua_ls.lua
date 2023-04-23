return {
  settings = {
    Lua = {
      diagnostics = {
        -- globals = { 'hs', 'vim' },
        -- This seems to always generate false positives
        disable = { 'different-requires' },
      },

      format = {
        -- disable formatting in favor of stylua
        enable = vim.fn.executable('stylua') == 0,
      },

      workspace = {
        checkThirdParty = false,
      },

      runtime = {
        pathStrict = true
      }
    },
  },
}
