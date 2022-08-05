local packer = require('packer')

local function config(name)
  return "require('user.plugins." .. name .. "').config()"
end

local function setup(name)
  return "require('user.plugins." .. name .. "').setup()"
end

packer.startup({
  function(use)
    -- manage the package manager
    use('wbthomason/packer.nvim')

    -- speed up the lua loader
    use('lewis6991/impatient.nvim')

    -- flashy status bar
    use({
      'nvim-lualine/lualine.nvim',
      requires = {
        'arkav/lualine-lsp-progress',
        'kyazdani42/nvim-web-devicons',
      },
      config = config('lualine')
    })

    -- file explorer in sidebar
    use({
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v2.x',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons',
        'MunifTanjim/nui.nvim',
      },
      config = config('neotree')
    })

    -- autodetect buffer formatting
    use({
      'tpope/vim-sleuth',
      config = config('vim-sleuth'),
    })

    -- Useful startup text, menu
    use({
      'goolord/alpha-nvim',
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = config('alpha'),
    })

    -- highlight color strings
    use({
      'norcalli/nvim-colorizer.lua',
      config = config('nvim-colorizer'),
    })

    -- better start/end matching
    use({
      'andymass/vim-matchup',
      requires = 'nvim-lua/plenary.nvim',
      config = config('vim-matchup')
    })

    -- preserve layout when closing buffers; used for <leader>k
    use({
      'moll/vim-bbye',
      config = config('vim-bbye')
    })

    -- more efficient cursorhold behavior
    -- see https://github.com/neovim/neovim/issues/12587
    use('antoinemadec/FixCursorHold.nvim')

    -- gc for commenting code blocks
    use('tpope/vim-commentary')

    -- EditorConfig
    use({
      'editorconfig/editorconfig-vim',
      setup = setup('editorconfig-vim')
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
      config = config('undotree')
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
          -- 'SmiteshP/nvim-navic',
          'jason0x43/nvim-navic',
          branch = 'symbolinformation-support',
          config = function()
            require('nvim-navic').setup()
          end
        },
      },
      run = ':TSUpdate',
      config = config('nvim-treesitter')
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
        'nvim-telescope/telescope-ui-select.nvim',
      },
      config = config('telescope')
    })

    -- filetype plugins
    use('tpope/vim-markdown')
    use({
      'mzlogin/vim-markdown-toc',
      setup = setup('vim-markdown-toc')
    })
    use('tpope/vim-classpath')
    use('MaxMEllon/vim-jsx-pretty')
    use('vim-scripts/applescript.vim')
    use('vim-scripts/Textile-for-VIM')

    -- native LSP
    use({
      'williamboman/mason.nvim',
      config = function()
        require('mason').setup()
      end
    })
    use({
      'williamboman/mason-lspconfig.nvim',
      config = function()
        -- setup mason-lspconfig before configuring any lsp servers
        require('mason-lspconfig').setup()
      end
    })
    use({
      'neovim/nvim-lspconfig',
      config = "require('user.lsp').config()",
    })
    use({
      'jose-elias-alvarez/null-ls.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = config('null-ls')
    })
    use('b0o/schemastore.nvim')

    -- highlight current word
    use({
      'RRethy/vim-illuminate',
      -- disabled because it conflicts with matchup's highlighting for
      -- function/end and if/end pairs
      disable = true,
      setup = setup('vim-illuminate')
    })

    -- better git diff views
    use({
      'sindrets/diffview.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons',
      },
      config = function()
        require('diffview').setup()
      end
    })

    -- better git decorations
    use({
      'lewis6991/gitsigns.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = config('gitsigns')
    })

    -- completion
    use({
      {
        'hrsh7th/nvim-cmp',
        config = config('nvim-cmp')
      },
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
            event = { 'VimEnter' },
            config = function()
              vim.defer_fn(function()
                require('copilot').setup()
              end, 100)
            end
          },
        }
      },
    })

    -- startup time profiling
    use('dstein64/vim-startuptime')

    -- diagnostics display
    use({
      'folke/trouble.nvim',
      requires = 'kyazdani42/nvim-web-devicons',
      config = function()
        require('trouble').setup()
      end
    })

    -- show available code action indiciator
    use({
      'kosayoda/nvim-lightbulb',
      config = function()
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          pattern = '*',
          callback = function()
            require('nvim-lightbulb').update_lightbulb()
          end
        })
      end
    })
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
