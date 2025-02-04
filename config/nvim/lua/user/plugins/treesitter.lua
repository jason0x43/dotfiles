return {
  'nvim-treesitter/nvim-treesitter',

  dependencies = {
    'nvim-lua/plenary.nvim',
    -- provide TSCaptureUnderCursor command
    'nvim-treesitter/playground',
  },

  main = 'nvim-treesitter.configs',

  opts = {
    auto_install = true,

    sync_install = true,

    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    matchup = {
      enable = true,
    },
    context_commentstring = {
      enable = true,
    },
  },
}
