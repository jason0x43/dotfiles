return {
  -- better start/end matching
  {
    'andymass/vim-matchup',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  },

  -- JSON schemas
  'b0o/schemastore.nvim',

  -- better git diff views
  {
    'sindrets/diffview.nvim',
    cmd = 'DiffviewOpen',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = true,
  },

  -- Git tools
  'tpope/vim-fugitive',

  -- Auto-set indentation
  {
    'tpope/vim-sleuth',

    config = function()
      -- Disable sleuth for markdown files as it slows the load time
      -- significantly
      vim.g.sleuth_markdown_heuristics = 0
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
    lazy = true,
    cmd = 'Tig',
  },

  -- undotree
  {
    dir = '/Users/jason/.config/nvim/lua/undotree-nvim',
    main = 'undotree-nvim',
    dependencies = 'echasnovski/mini.nvim',
    config = true,
    opts = function()
      vim.keymap.set('n', '<leader>u', function()
        require('undotree-nvim').undotree()
      end)
      return {}
    end,
  },

  -- spelling
  {
    'ravibrock/spellwarn.nvim',
    event = 'VeryLazy',
    config = true,
  },
}
