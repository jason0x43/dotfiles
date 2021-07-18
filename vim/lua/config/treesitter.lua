local util = require('util')

require('nvim-treesitter.configs').setup({
  ensure_installed = 'maintained',
  highlight = {
    enable = true,
    -- this option prevents treesitter highlighting from breaking indenting
    -- see https://github.com/nvim-treesitter/nvim-treesitter/discussions/1271#discussioncomment-795299
    -- this should be set to a list of filetypes, but that doesn't work
    -- https://github.com/nvim-treesitter/nvim-treesitter#modules
    additional_vim_regex_highlighting = true
  },
  indent = {
    enable = true,
    -- indenting is currently broken for several languages, particularly for doc
    -- comments
    disable = vim.list_extend({
      'cpp',
      'python',
    }, util.ts_types),
  },
})
