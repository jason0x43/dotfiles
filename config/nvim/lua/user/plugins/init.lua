return {
  -- functions used by many plugins
  'nvim-lua/plenary.nvim',

  -- icons used by many plugins
  'nvim-tree/nvim-web-devicons',

  -- highlight color strings
  {
    'norcalli/nvim-colorizer.lua',
    event = 'BufEnter',
    config = function()
      require('colorizer').setup({ '*' }, {
        names = false,
        rgb_fn = true,
      })
    end,
  },

  -- better start/end matching
  {
    'andymass/vim-matchup',
    dependencies = 'plenary.nvim',
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  },

  -- preserve layout when closing buffers; used for <leader>k
  {
    'moll/vim-bbye',
    event = 'BufEnter',
    config = function()
      local util = require('user.util')
      util.lmap('k', '<cmd>Bdelete<cr>')
      util.lmap('K', '<cmd>Bdelete!<cr>')
    end,
  },

  -- gc for commenting code blocks
  {
    'tpope/vim-commentary',
    event = 'BufEnter',
  },

  -- EditorConfig
  {
    'editorconfig/editorconfig-vim',
    init = function()
      -- Don't let editorconfig set the max line -- it's handled via an
      -- autocommand
      vim.g.EditorConfig_max_line_indicator = 'none'
      vim.g.EditorConfig_disable_rules = {
        'trim_trailing_whitespace',
        'insert_final_newline',
      }
    end,
  },

  -- git utilities
  {
    'tpope/vim-fugitive',
    event = 'BufEnter',
  },

  -- support for repeating mapped commands
  {
    'tpope/vim-repeat',
    event = 'BufEnter',
  },

  -- for manipulating parens and such
  {
    'tpope/vim-surround',
    event = 'BufEnter',
  },

  -- easy vertical alignment of code elements
  {
    'junegunn/vim-easy-align',
    cmd = 'EasyAlign',
  },

  -- show semantic file location (e.g., what function you're in)
  {
    'SmiteshP/nvim-navic',
    dependencies = 'nvim-treesitter',
    config = function()
      require('nvim-navic').setup()
    end,
  },

  -- filetype plugins
  {
    'tpope/vim-markdown',
    ft = 'markdown',
  },
  {
    'mzlogin/vim-markdown-toc',
    ft = 'markdown',
    init = function()
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

  -- native LSP
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- setup mason and mason-lspconfig before configuring any lsp servers
      require('mason').setup({
        ui = {
          border = 'rounded',
        },
      })
      require('mason-lspconfig').setup()
      require('user.lsp').config()
    end,
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
  },

  -- JSON schemas
  'b0o/schemastore.nvim',

  -- highlight current word
  {
    'RRethy/vim-illuminate',
    -- disabled because it conflicts with matchup's highlighting for
    -- function/end and if/end pairs
    disable = true,
    init = function()
      vim.g.Illuminate_highlightPriority = -10
    end,
  },

  -- better git diff views
  {
    'sindrets/diffview.nvim',
    cmd = 'DiffviewOpen',
    dependencies = {
      'plenary.nvim',
      'nvim-web-devicons',
    },
    config = function()
      require('diffview').setup()
    end,
  },

  -- better git decorations
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufEnter',
    dependencies = 'plenary.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '▋' },
          change = { text = '▋' },
        },
      })
    end,
  },

  -- diagnostics display
  {
    'folke/trouble.nvim',
    event = 'BufEnter',
    dependencies = 'nvim-web-devicons',
    config = function()
      require('trouble').setup()
    end,
  },

  -- Laravel Blade template support
  'jwalton512/vim-blade',

  -- Autosave files
  {
    'Pocco81/auto-save.nvim',
    config = function()
      require('auto-save').setup({
        condition = function(buf)
          return vim.bo[buf].filetype == 'rust'
        end,
      })
    end,
  },
}
