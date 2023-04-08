local max_filesize = 1000000

return {
  'nvim-treesitter/nvim-treesitter',

  dependencies = {
    'nvim-lua/plenary.nvim',
    -- provide TSCaptureUnderCursor command
    'nvim-treesitter/playground',
    -- set proper commentstring for embedded languages
    'JoosepAlviste/nvim-ts-context-commentstring',
  },

  config = function()
    local configs = require('nvim-treesitter.configs')

    local config = {
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
    }

    config.ensure_installed = {
      'bash',
      'c',
      'comment',
      'cpp',
      'css',
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
      'svelte',
      'swift',
      'tsx',
      'typescript',
      'vim',
      'yaml',
    }

    configs.setup(config)
  end,
}
