return {
  {
    'tpope/vim-markdown',
    ft = 'markdown',
  },

  {
    'mzlogin/vim-markdown-toc',
    ft = 'markdown',
    config = function()
      vim.g.vmt_auto_update_on_save = 0
    end,
  },

  {
    'tpope/vim-classpath',
    ft = 'java',
  },

  {
    'MaxMEllon/vim-jsx-pretty',
    ft = { 'javascriptreact', 'typescriptreact' },
  },

  'vim-scripts/applescript.vim',
  'vim-scripts/Textile-for-VIM',
  'mustache/vim-mustache-handlebars',
  'jwalton512/vim-blade',
}
