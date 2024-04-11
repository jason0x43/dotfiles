return {
  -- native LSP
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('user.lsp').config()
    end,
  },

  -- LSP settings manager; must be setup **before** any language servers are
  -- configured
  {
    'folke/neoconf.nvim',
    config = true,
    priority = 100,
  },

  -- helpers for editing neovim lua; must be setup **before** any language
  -- servers are configured
  {
    'folke/neodev.nvim',
    priority = 100,
    config = true,
  },

  -- language server installer; must be setup before null-ls to ensure
  -- mason-managed tools are available in the path
  {
    'williamboman/mason.nvim',
    priority = 100,
    build = ':MasonUpdate',
    opts = {
      ui = {
        border = 'rounded',
      },
    },
  },

  -- basic language server support
  'neovim/nvim-lspconfig',

  -- language server manager
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup()
      require('user.lsp').config()

      -- use mason's automatic server startup functionality
      require('mason-lspconfig').setup_handlers({
        function(server_name)
          require('user.lsp').setup(server_name)
        end,
      })

      -- manually setup sourcekit
      if vim.fn.executable('sourcekit-lsp') ~= 0 then
        require('user.lsp').setup('sourcekit')
      end

      vim.keymap.set('n', '<leader>a', function()
        vim.lsp.buf.code_action()
      end)
    end,
  },

  -- diagnostics display
  {
    'folke/trouble.nvim',
    event = 'BufEnter',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = true,
  },

  -- virtual text diagnostics
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = true,
    enabled = false,
    opts = function()
      vim.diagnostic.config({
        virtual_text = false,
      })
      vim.keymap.set('n', '<leader>l', require('lsp_lines').toggle)
      return {}
    end,
  },

  -- copilot integration
  {
    'zbirenbaum/copilot.lua',
    opts = {
      event = 'InsertEnter',
      suggestion = {
        enabled = false,
        auto_trigger = true,
      },
      panel = { enabled = false },
      filetypes = {
        ['*'] = function()
          return not require('user.util').is_large_file(0)
        end,
      },
    },
  },

  {
    'SmiteshP/nvim-navic',
    config = true,
  },

  {
    'utilyre/barbecue.nvim',
    name = 'barbecue',
    version = '*',
    dependencies = {
      'SmiteshP/nvim-navic',
      'nvim-tree/nvim-web-devicons',
    },
    opts = function()
      local colors = require('user.themes.wezterm').load_colors()
      return {
        theme = {
          normal = { fg = colors.fg_0, bg = colors.bg_1 }
        },
      }
    end,
  },
}
