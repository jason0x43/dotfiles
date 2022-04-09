local packer = require('packer')

packer.startup({
  function(use)
    -- manage the package manager
    use({
      'wbthomason/packer.nvim',
      requires = 'nvim-lua/plenary.nvim',
    })

    -- speed up the lua loader
    use({
      'lewis6991/impatient.nvim',
      requires = 'nvim-lua/plenary.nvim',
    })

    -- flashy status bar
    use({
      'nvim-lualine/lualine.nvim',
      requires = {
        'arkav/lualine-lsp-progress',
        'kyazdani42/nvim-web-devicons',
      },
      config = "require('user.plugins.lualine').config()",
    })

    -- file explorer in sidebar
    use({
      'kyazdani42/nvim-tree.lua',
      config = "require('user.plugins.nvim-tree').config()",
    })

    -- autodetect buffer formatting
    use({
      'tpope/vim-sleuth',
      config = "require('user.plugins.vim-sleuth').config()",
    })

    -- Useful startup text, menu
    use({
      'goolord/alpha-nvim',
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = "require('user.plugins.alpha').config()",
    })

    -- highlight color strings
    use({
      'norcalli/nvim-colorizer.lua',
      config = "require('user.plugins.nvim-colorizer').config()",
    })

    -- better start/end matching
    use({
      'andymass/vim-matchup',
      requires = 'nvim-lua/plenary.nvim',
      config = "require('user.plugins.vim-matchup').config()",
    })

    -- preserve layout when closing buffers; used for <leader>k
    use({
      'moll/vim-bbye',
      config = "require('user.plugins.vim-bbye').config()",
    })

    -- more efficient cursorhold behavior
    -- see https://github.com/neovim/neovim/issues/12587
    use('antoinemadec/FixCursorHold.nvim')

    -- gc for commenting code blocks
    use('tpope/vim-commentary')

    -- EditorConfig
    use({
      'editorconfig/editorconfig-vim',
      setup = "require('user.plugins.editorconfig-vim').setup()",
    })

    -- git utilities
    use('tpope/vim-fugitive')

    -- support for repeating mapped commands
    use('tpope/vim-repeat')

    -- for manipulating parens and such
    use('tpope/vim-surround')

    -- easy vertical alignment of code elements
    use('junegunn/vim-easy-align')

    -- visualize the undo tree
    use({
      'mbbill/undotree',
      config = "require('user.plugins.undotree').config()",
    })

    -- for filetype features like syntax highlighting and indenting
    use({
      'nvim-treesitter/nvim-treesitter',
      requires = {
        'nvim-lua/plenary.nvim',
        -- provide TSHighlightCapturesUnderCursor command
        'nvim-treesitter/playground',
        -- set proper commentstring for embedded languages
        'JoosepAlviste/nvim-ts-context-commentstring',
        -- show semantic file location (e.g., what function you're in)
        {
          'SmiteshP/nvim-gps',
          config = "require('user.plugins.nvim-gps').config()",
        },
      },
      run = ':TSUpdate',
      config = "require('user.plugins.nvim-treesitter').config()",
    })

    -- fuzzy finding
    use({
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
      },
      config = "require('user.plugins.telescope').config()",
    })

    -- filetype plugins
    use('tpope/vim-markdown')
    use({
      'mzlogin/vim-markdown-toc',
      setup = "require('user.plugins.vim-markdown-toc').setup()",
    })
    use('tpope/vim-classpath')
    use('MaxMEllon/vim-jsx-pretty')
    use('vim-scripts/applescript.vim')
    use('vim-scripts/Textile-for-VIM')

    -- native LSP
    use({
      'neovim/nvim-lspconfig',
      config = "require('user.lsp').config()",
      requires = {
        'nvim-lua/plenary.nvim',
        {
          'jose-elias-alvarez/null-ls.nvim',
          requires = 'nvim-lua/plenary.nvim',
          config = "require('user.plugins.null-ls').config()",
        },
        {
          'williamboman/nvim-lsp-installer',
          requires = 'nvim-lua/plenary.nvim',
          config = "require('user.plugins.nvim-lsp-installer').config()",
        },
        'b0o/schemastore.nvim',
      },
    })

    -- highlight current word
    use({
      'RRethy/vim-illuminate',
      -- disabled because it conflicts with matchup's highlighting for
      -- function/end and if/end pairs
      disable = true,
      setup = "require('user.plugins.vim-illuminate').setup()",
    })

    -- better git diff views
    use({
      'sindrets/diffview.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons',
      },
      config = "require('user.plugins.diffview').config()",
    })

    -- better git decorations
    use({
      'lewis6991/gitsigns.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = "require('user.plugins.gitsigns').config()",
    })

    -- completion
    use({
      'hrsh7th/nvim-cmp',
      requires = {
        'L3MON4D3/LuaSnip',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-nvim-lsp',
        'saadparwaiz1/cmp_luasnip',
        {
          'zbirenbaum/copilot-cmp',
          requires = { 
            {
              'zbirenbaum/copilot.lua',
              config = "require('user.plugins.copilot').config()"
            },
          }
        },
      },
      config = "require('user.plugins.nvim-cmp').config()",
    })

    -- startup time profiling
    use('dstein64/vim-startuptime')

    -- diagnostics display
    use({
      'folke/trouble.nvim',
      requires = 'kyazdani42/nvim-web-devicons',
      config = "require('user.plugins.trouble').config()",
    })

    -- show available code action indiciator
    use({
      'kosayoda/nvim-lightbulb',
      config = "require('user.plugins.nvim-lightbulb').config()",
    })

    -- use('github/copilot.vim')
  end,

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
