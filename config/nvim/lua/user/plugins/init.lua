local packer = require('packer')

local function config(name)
  return "require('user.plugins." .. name .. "').config()"
end

local function setup(name)
  return "require('user.plugins." .. name .. "').setup()"
end

packer.startup({
  {
    -- manage the package manager
    'wbthomason/packer.nvim',

    -- speed up the lua loader
    'lewis6991/impatient.nvim',

    -- flashy status bar
    {
      'nvim-lualine/lualine.nvim',
      requires = {
        'arkav/lualine-lsp-progress',
        'kyazdani42/nvim-web-devicons',
      },
      config = config('lualine'),
    },

    -- file explorer in sidebar
    {
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v2.x',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons',
        'MunifTanjim/nui.nvim',
      },
      config = config('neotree'),
    },

    -- autodetect buffer formatting
    {
      'tpope/vim-sleuth',
      config = config('vim-sleuth'),
    },

    -- Useful startup text, menu
    {
      'goolord/alpha-nvim',
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = config('alpha'),
    },

    -- highlight color strings
    {
      'norcalli/nvim-colorizer.lua',
      config = config('nvim-colorizer'),
    },

    -- better start/end matching
    {
      'andymass/vim-matchup',
      requires = 'nvim-lua/plenary.nvim',
      config = config('vim-matchup'),
    },

    -- preserve layout when closing buffers; used for <leader>k
    {
      'moll/vim-bbye',
      config = config('vim-bbye'),
    },

    -- more efficient cursorhold behavior
    -- see https://github.com/neovim/neovim/issues/12587
    'antoinemadec/FixCursorHold.nvim',

    -- gc for commenting code blocks
    'tpope/vim-commentary',

    -- EditorConfig
    {
      'editorconfig/editorconfig-vim',
      setup = setup('editorconfig-vim'),
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
      config = config('undotree'),
    },

    -- for filetype features like syntax highlighting and indenting
    {
      'nvim-treesitter/nvim-treesitter',
      requires = {
        'nvim-lua/plenary.nvim',
        -- provide TSHighlightCapturesUnderCursor command
        'nvim-treesitter/playground',
        -- set proper commentstring for embedded languages
        'JoosepAlviste/nvim-ts-context-commentstring',
        -- show semantic file location (e.g., what function you're in)
        {
          'SmiteshP/nvim-navic',
          config = function()
            require('nvim-navic').setup()
          end,
        },
      },
      run = ':TSUpdate',
      config = config('nvim-treesitter'),
    },

    -- fuzzy finding
    {
      'nvim-telescope/telescope.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons',
        'natecraddock/telescope-zf-native.nvim',
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          run = 'make',
        },
        {
          'nvim-telescope/telescope-symbols.nvim',
          requires = 'nvim-lua/plenary.nvim',
        },
        {
          'nvim-telescope/telescope-file-browser.nvim',
          requires = 'nvim-lua/plenary.nvim',
        },
        'nvim-telescope/telescope-live-grep-raw.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
      },
      config = config('telescope'),
    },

    -- filetype plugins
    'tpope/vim-markdown',
    {
      'mzlogin/vim-markdown-toc',
      setup = setup('vim-markdown-toc'),
    },
    'tpope/vim-classpath',
    'MaxMEllon/vim-jsx-pretty',
    'vim-scripts/applescript.vim',
    'vim-scripts/Textile-for-VIM',

    -- native LSP
    {
      'williamboman/mason.nvim',
      config = function()
        require('mason').setup()
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
      config = "require('user.lsp').config()",
    },
    {
      'jose-elias-alvarez/null-ls.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = config('null-ls'),
    },
    'b0o/schemastore.nvim',

    -- highlight current word
    {
      'RRethy/vim-illuminate',
      -- disabled because it conflicts with matchup's highlighting for
      -- function/end and if/end pairs
      disable = true,
      setup = setup('vim-illuminate'),
    },

    -- better git diff views
    {
      'sindrets/diffview.nvim',
      requires = {
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
      requires = 'nvim-lua/plenary.nvim',
      config = config('gitsigns'),
    },

    -- completion
    {
      {
        'hrsh7th/nvim-cmp',
        config = config('nvim-cmp'),
      },
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      {
        'zbirenbaum/copilot-cmp',
        config = function()
          require('copilot_cmp').setup()
        end,
        requires = {
          {
            'zbirenbaum/copilot.lua',
            event = { 'VimEnter' },
            config = function()
              vim.defer_fn(function()
                require('copilot').setup()
              end, 100)
            end,
          },
        },
      },
    },

    -- startup time profiling
    'dstein64/vim-startuptime',

    -- diagnostics display
    {
      'folke/trouble.nvim',
      requires = 'kyazdani42/nvim-web-devicons',
      config = config('trouble'),
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
  },

  config = {
    display = {
      open_fn = function()
        -- show packer output in a float
        return require('packer.util').float({ border = 'rounded' })
      end,
    },
  },
})

return packer
