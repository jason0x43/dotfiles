return {
  -- speed up the lua loader
  'lewis6991/impatient.nvim',

  -- highlight color strings
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('user.req')('colorizer', 'setup', { '*' }, {
        names = false,
        rgb_fn = true,
      })
    end,
  },

  -- better start/end matching
  {
    'andymass/vim-matchup',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  },

  -- preserve layout when closing buffers; used for <leader>k
  {
    'moll/vim-bbye',
    config = function()
      local util = require('user.util')
      util.lmap('k', '<cmd>Bdelete<cr>')
      util.lmap('K', '<cmd>Bdelete!<cr>')
    end,
  },

  -- more efficient cursorhold behavior
  -- see https://github.com/neovim/neovim/issues/12587
  'antoinemadec/FixCursorHold.nvim',

  -- gc for commenting code blocks
  'tpope/vim-commentary',

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
  'tpope/vim-fugitive',

  -- support for repeating mapped commands
  'tpope/vim-repeat',

  -- for manipulating parens and such
  'tpope/vim-surround',

  -- easy vertical alignment of code elements
  'junegunn/vim-easy-align',

  -- visualize the undo tree
  {
    'mbbill/undotree',
    config = function()
      vim.g.undotree_DiffAutoOpen = 0
      vim.g.undotree_SetFocusWhenToggle = 1
      require('user.util').lmap('u', '<cmd>UndotreeToggle<cr>')
    end,
  },

  -- show semantic file location (e.g., what function you're in)
  {
    'SmiteshP/nvim-navic',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('nvim-navic').setup()
    end,
  },

  -- filetype plugins
  'tpope/vim-markdown',
  {
    'mzlogin/vim-markdown-toc',
    init = function()
      vim.g.vmt_auto_update_on_save = 0
    end,
  },
  'tpope/vim-classpath',
  'MaxMEllon/vim-jsx-pretty',
  'vim-scripts/applescript.vim',
  'vim-scripts/Textile-for-VIM',

  -- native LSP
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup({
        ui = {
          border = 'rounded',
        },
      })
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      -- setup mason-lspconfig before configuring any lsp servers
      require('mason-lspconfig').setup()
    end,
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
			require('user.lsp').config()
		end
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
    dependencies = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      require('diffview').setup()
    end,
  },

  -- better git decorations
  {
    'lewis6991/gitsigns.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('user.req')('gitsigns', 'setup', {
        signs = {
          add = { text = '▋' },
          change = { text = '▋' },
        },
      })
    end,
  },

  -- startup time profiling
  'dstein64/vim-startuptime',

  -- diagnostics display
  {
    'folke/trouble.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
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
