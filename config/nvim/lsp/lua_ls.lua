local C = require('user.util.lsp').make_config()

C.settings = {
  Lua = {
    format = {
      -- disable formatting in favor of stylua
      enable = vim.fn.executable('stylua') == 0,
    },

    workspace = {
      checkThirdParty = false,
    },

    runtime = {
      pathStrict = true,
    },

    type = {
      checkTableShape = true,
    },
  },
}

return C
