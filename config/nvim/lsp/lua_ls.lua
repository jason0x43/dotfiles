---@type vim.lsp.Config
local config = {
  settings = {
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
  },
}

vim.lsp.config('lua_ls', config)
