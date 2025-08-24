---@type vim.lsp.Config
local config = {
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
}

vim.lsp.config('yamlls', config)
