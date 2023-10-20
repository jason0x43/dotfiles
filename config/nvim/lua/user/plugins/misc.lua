return {
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
    'ojroques/nvim-bufdel',
    config = true,
    opts = function()
      vim.keymap.set('n', '<leader>k', function()
        vim.cmd('BufDel')
      end)
      vim.keymap.set('n', '<leader>K', function()
        vim.cmd('BufDel!')
      end)
      return {
        quit = false,
      }
    end,
  },

  -- gc for commenting code blocks
  'tpope/vim-commentary',

  -- git utilities
  'tpope/vim-fugitive',

  -- for manipulating parens and such
  'tpope/vim-surround',

  -- for repeating surround commands
  'tpope/vim-repeat',

  -- show semantic file location (e.g., what function you're in)
  {
    'SmiteshP/nvim-navic',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
  },

  -- JSON schemas
  'b0o/schemastore.nvim',

  -- better git diff views
  {
    'sindrets/diffview.nvim',
    cmd = 'DiffviewOpen',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = true,
  },

  -- better git decorations
  {
    'lewis6991/gitsigns.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '▋' },
          change = { text = '▋' },
        },
      })
    end,
  },

  -- Auto-set indentation
  {
    'tpope/vim-sleuth',

    config = function()
      -- Disable sleuth for markdown files as it slows the load time
      -- significantly
      vim.g.sleuth_markdown_heuristics = 0
    end,
  },

  -- tig in a float
  {
    dir = '/Users/jason/.config/nvim/lua/tig-nvim',
    cond = vim.fn.executable('tig') == 1,
    main = 'tig-nvim',
    config = true,
  },

  -- fzf-based undotree
  {
    dir = '/Users/jason/.config/nvim/lua/undotree-nvim',
    main = 'undotree-nvim',
    dependencies = 'ibhagwan/fzf-lua',
    config = true,
    opts = function()
      vim.keymap.set('n', '<leader>u', function()
        require('undotree-nvim').undotree()
      end)
      return {}
    end,
  },

  'mbbill/undotree',
}
