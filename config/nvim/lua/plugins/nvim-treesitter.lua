local config = {
  highlight = {
    enable = true,
    -- this option prevents treesitter highlighting from breaking indenting
    -- see https://github.com/nvim-treesitter/nvim-treesitter/discussions/1271#discussioncomment-795299
    -- this should be set to a list of filetypes, but that doesn't work
    -- https://github.com/nvim-treesitter/nvim-treesitter#modules
    -- additional_vim_regex_highlighting = true
    additional_vim_regex_highlighting = require('util').ts_types,
  },
  indent = {
    enable = true,
    -- indenting is currently broken for several languages, particularly for doc
    -- comments
    -- disable = vim.list_extend({
    --   'cpp',
    --   'python',
    -- }, require(
    --   'util'
    -- ).ts_types),
    disable = require('util').ts_types,
  },
  matchup = {
    enable = true,
  },
  context_commentstring = {
    enable = true
  }
}

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
  'yaml',
}

require('nvim-treesitter.configs').setup(config)
