---@type vim.lsp.Config
local config = {
  settings = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = 'ignore',
      },
    },
    less = {
      validate = true,
    },
    scss = {
      validate = true,
    },
  },
}

vim.lsp.config('cssls', config)
