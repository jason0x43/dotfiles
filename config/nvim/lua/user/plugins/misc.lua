return {
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
    'famiu/bufdelete.nvim',
    event = 'BufEnter',
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
  {
    'tpope/vim-commentary',
    event = 'BufEnter',
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
    config = true,
  },

  -- JSON schemas
  'b0o/schemastore.nvim',

  -- better git diff views
  {
    'sindrets/diffview.nvim',
    cmd = 'DiffviewOpen',
    dependencies = {
      'plenary.nvim',
      'nvim-web-devicons',
    },
    config = true,
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
    dir = '/Users/jason/.config/nvim/lua/tig-lua',
		main = 'tig-lua',
    config = true
  },
}
