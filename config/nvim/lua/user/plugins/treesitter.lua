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
      disable = function(_, buf)
        return require('user.util').is_large_file(buf)
      end,
    },
    indent = {
      enable = true,
      disable = function(_, buf)
        return require('user.util').is_large_file(buf)
      end,
    },
    matchup = {
      enable = true,
      disable = function(_, buf)
        return require('user.util').is_large_file(buf)
      end,
    },
    context_commentstring = {
      enable = true,
      disable = function(_, buf)
        return require('user.util').is_large_file(buf)
      end,
    },
  },
}
