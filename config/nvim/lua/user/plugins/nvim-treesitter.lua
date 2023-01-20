return {
  'nvim-treesitter/nvim-treesitter',

  dependencies = {
    'plenary.nvim',
    -- provide TSHighlightCapturesUnderCursor command
    'nvim-treesitter/playground',
    -- set proper commentstring for embedded languages
    'JoosepAlviste/nvim-ts-context-commentstring',
  },

  config = function()
    local configs = require('nvim-treesitter.configs')

    local config = {
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
