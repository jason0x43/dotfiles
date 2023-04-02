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
    'famiu/bufdelete.nvim',
    config = function()
      vim.keymap.set('n', '<leader>k', function()
        require('bufdelete').bufdelete(0)
      end)
      vim.keymap.set('n', '<leader>K', function()
        require('bufdelete').bufdelete(0, true)
      end)
    end,
  },

  -- gc for commenting code blocks
  'tpope/vim-commentary',

  -- git utilities
  'tpope/vim-fugitive',

  -- support for repeating mapped commands
  'tpope/vim-repeat',

  -- for manipulating parens and such
  'tpope/vim-surround',

  -- show semantic file location (e.g., what function you're in)
  {
    'SmiteshP/nvim-navic',
    dependencies = 'nvim-treesitter',
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

  -- Autosave files
  {
    'Pocco81/auto-save.nvim',
    config = function()
      require('auto-save').setup({
        condition = function(buf)
          return vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].filetype == 'rust'
        end,
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
    depends = 'ibhagwan/fzf-lua',
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
