---@type vim.lsp.Config
return {
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
