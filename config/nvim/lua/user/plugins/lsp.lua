local util = require('user.util')

return {
  -- native LSP
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Give LspInfo window a border
      require('lspconfig.ui.windows').default_options.border = 'rounded'
    end,
  },

  -- language server installer
  {
    'williamboman/mason.nvim',
    priority = 100,
    build = ':MasonUpdate',
    opts = function()
      util.user_cmd('MasonUpgrade', function()
        require('user.util.mason').upgrade()
      end)

      return {
        ui = {
          border = 'rounded',
        },
      }
    end,
  },

  -- language server manager
  {
    'williamboman/mason-lspconfig.nvim',
    config = true,
  },
}
