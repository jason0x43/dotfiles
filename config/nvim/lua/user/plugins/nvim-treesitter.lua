local M = {}

M.config = function()
  local configs = require('user.req')('nvim-treesitter.configs')
  if not configs then
    return
  end

  local legacy_filetypes = vim.list_extend({
    'html',
    'css',
    'scss',
    'lua',
    'java',
    'json',
    'python',
  }, require('user.util').ts_types)

  local config = {
    highlight = {
      enable = true,
      -- this option prevents treesitter highlighting from breaking indenting
      -- see https://github.com/nvim-treesitter/nvim-treesitter/discussions/1271#discussioncomment-795299
      -- this should be set to a list of filetypes, but that doesn't work
      -- https://github.com/nvim-treesitter/nvim-treesitter#modules
      -- additional_vim_regex_highlighting = true
      additional_vim_regex_highlighting = legacy_filetypes,
    },
    indent = {
      enable = true,
      -- indenting is currently broken for several languages, particularly for doc
      -- comments
      disable = legacy_filetypes,
    },
    matchup = {
      enable = true,
    },
    context_commentstring = {
      enable = true,
    },
  }

  if vim.fn.has('mac') == 1 then
    config.ensure_installed = 'maintained'
  else
    config.ensure_installed = {
      'bash',
      'c',
      'comment',
      'cpp',
      'dockerfile',
      'go',
      'html',
      'java',
      'javascript',
      'jsdoc',
      'json',
      'json5',
      'jsonc',
      'lua',
      'python',
      'rust',
      'scss',
      'swift',
      'tsx',
      'typescript',
      'vim',
      'yaml',
    }
  end

  configs.setup(config)
end

return M
