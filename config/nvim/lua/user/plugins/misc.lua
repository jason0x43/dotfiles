return {
  -- better start/end matching
  {
    'andymass/vim-matchup',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
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

  -- many things
  {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      require('mini.files').setup()
      vim.keymap.set('n', '<leader>n', function()
        MiniFiles.open(vim.api.nvim_buf_get_name(0))
      end)

      require('mini.extra').setup()
      require('mini.pick').setup()

      vim.ui.select = MiniPick.ui_select

      vim.keymap.set('n', '<leader>f', function()
        local in_worktree = require('user.util').in_git_dir()
        if in_worktree then
          MiniPick.builtin.files({ tool = 'git' })
        else
          MiniPick.builtin.files()
        end
      end)
      vim.keymap.set('n', '<leader>g', function()
        MiniPick.builtin.grep_live()
      end)
      vim.keymap.set('n', '<leader>e', function()
        MiniExtra.pickers.diagnostic({ scope = 'current' })
      end)
      vim.keymap.set('n', '<leader>b', function()
        MiniPick.builtin.buffers()
      end)
      vim.keymap.set('n', '<leader>h', function()
        MiniPick.builtin.help()
      end)
      vim.keymap.set('n', '<leader>lr', function()
        MiniExtra.pickers.lsp({ scope = "references" })
      end)

      require('mini.bufremove').setup()
      vim.keymap.set('n', '<leader>k', function()
        MiniBufremove.delete()
      end)
      vim.keymap.set('n', '<leader>K', function()
        MiniBufremove.wipeout()
      end)
    end,
  },
}
