local M = {}

M.config = {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'hs', 'vim', 'packer_plugins' },
        -- This seems to always generate false positives
        disable = { 'different-requires' },
      },
      workspace = {
        checkThirdParty = false,
      }
    },
  },
}

return M

