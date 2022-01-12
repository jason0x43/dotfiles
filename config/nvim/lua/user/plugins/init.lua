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
      config = "require('user.plugins.lualine')",
    })

    -- file explorer in sidebar
    use({
      'kyazdani42/nvim-tree.lua',
      setup = function()
        -- close the tree after opening a file
        vim.g.nvim_tree_quit_on_open = 1
      end,
      config = function()
        require('user.req')('nvim-tree', function(nvim_tree)
          nvim_tree.setup({
            update_focused_file = {
              enable = true,
            },
            diagnostics = {
              enable = true,
            },
            view = {
              side = 'right',
              width = 40,
            },
            git = {
              ignore = true,
            },
          })

          require('user.util').lmap('n', '<cmd>NvimTreeToggle<cr>')
        end)
      end,
    })

    -- autodetect buffer formatting
    use({
      'tpope/vim-sleuth',
      config = function()
        -- Disable sleuth for markdown files as it slows the load time
        -- significantly
        vim.cmd('autocmd FileType markdown :let b:sleuth_automatic = 0')
      end,
    })

    -- Useful startup text, menu
    use({
      'goolord/alpha-nvim',
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = "require('user.plugins.alpha')",
    })

    -- highlight color strings
    use({
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('user.req')('colorizer', 'setup', { '*' }, { names = false })
      end,
    })

    -- better start/end matching
    use({
      'andymass/vim-matchup',
      requires = 'nvim-lua/plenary.nvim',
      config = function()
        vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      end,
    })

    -- preserve layout when closing buffers; used for <leader>k
    use({
      'moll/vim-bbye',
      config = function()
        local util = require('user.util')
        util.lmap('k', '<cmd>Bdelete<cr>')
        util.lmap('K', '<cmd>Bdelete!<cr>')
      end,
    })

    -- more efficient cursorhold behavior
    -- see https://github.com/neovim/neovim/issues/12587
    use('antoinemadec/FixCursorHold.nvim')

    -- gc for commenting code blocks
    use('tpope/vim-commentary')

    -- EditorConfig
    use({
      'editorconfig/editorconfig-vim',
      setup = function()
        -- Don't let editorconfig set the max line -- it's handled via an
        -- autocommand
        vim.g.EditorConfig_max_line_indicator = 'none'
      end,
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
      config = function()
        vim.g.undotree_DiffAutoOpen = 0
        vim.g.undotree_SetFocusWhenToggle = 1
        require('user.util').lmap('u', '<cmd>UndotreeToggle<cr>')
      end,
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
          config = function()
            require('user.req')('nvim-gps', 'setup')
          end,
        },
      },
      run = ':TSUpdate',
      config = "require('user.plugins.nvim-treesitter')",
    })

    -- fuzzy finding
    use({
      'nvim-telescope/telescope.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons',
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          run = 'make',
          config = function()
            require('user.req')('telescope', 'load_extension', 'fzf')
          end,
        },
        {
          'nvim-telescope/telescope-symbols.nvim',
          requires = 'nvim-lua/plenary.nvim',
        },
      },
      config = "require('user.plugins.telescope')",
    })

    -- easier movement between vim and tmux panes, and between vim panes
    use({
      'numToStr/Navigator.nvim',
      cond = function()
        return vim.fn.getenv('TMUX') ~= vim.NIL
      end,
      config = function()
        require('user.req')('Navigator', function(Navigator)
          Navigator.setup()

          local nmap = require('user.util').nmap
          nmap('<C-j>', '<cmd>lua require("Navigator").down()<cr>')
          nmap('<C-h>', '<cmd>lua require("Navigator").left()<cr>')
          nmap('<C-k>', '<cmd>lua require("Navigator").up()<cr>')
          nmap('<C-l>', '<cmd>lua require("Navigator").right()<cr>')
        end)
      end,
    })

    -- filetype plugins
    use('tpope/vim-markdown')
    use({
      'mzlogin/vim-markdown-toc',
      setup = function()
        vim.g.vmt_auto_update_on_save = 0
      end,
    })
    use('tpope/vim-classpath')
    use('MaxMEllon/vim-jsx-pretty')
    use('vim-scripts/applescript.vim')
    use('vim-scripts/Textile-for-VIM')

    -- native LSP
    use({
      'neovim/nvim-lspconfig',
      config = "require('user.lsp')",
      requires = {
        'nvim-lua/plenary.nvim',
        {
          'jose-elias-alvarez/null-ls.nvim',
          requires = 'nvim-lua/plenary.nvim',
          config = "require('user.plugins.null-ls')",
        },
        {
          'williamboman/nvim-lsp-installer',
          requires = 'nvim-lua/plenary.nvim',
          config = function()
            require('user.req')('nvim-lsp-installer', function(installer)
              local lsp = require('user.lsp')
              installer.on_server_ready(function(server)
                local config = lsp.get_lsp_config(server.name)
                server:setup(config)
              end)
            end)
          end,
        },
        'b0o/schemastore.nvim',
      },
    })

    -- show buffer symbols, functions, etc in sidebar
    use({
      'simrat39/symbols-outline.nvim',
      setup = function()
        vim.g.symbols_outline = {
          auto_preview = false,
          width = 30,
          relative_width = false,
        }
      end,
      config = function()
        local util = require('user.util')
        util.augroup('init_symbols_outline', {
          'FileType Outline setlocal signcolumn=no',
        })
        util.lmap('o', '<cmd>SymbolsOutline<cr>')
      end,
    })

    -- highlight current word
    use({
      'RRethy/vim-illuminate',
      -- disabled because it conflicts with matchup's highlighting for
      -- function/end and if/end pairs
      disable = true,
      setup = function()
        vim.g.Illuminate_highlightPriority = -10
      end,
    })

    -- better git diff views
    use({
      'sindrets/diffview.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons',
      },
      config = function()
        require('user.req')('diffview', 'setup')
      end,
    })

    -- better git decorations
    use({
      'lewis6991/gitsigns.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = function()
        require('user.req')('gitsigns', 'setup', {
          signs = {
            add = { text = '▋' },
            change = { text = '▋' },
          },
        })
      end,
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
      },
      config = "require('user.plugins.nvim-cmp')",
    })

    -- startup time profiling
    use('dstein64/vim-startuptime')

    -- diagnostics display
    use({
      'folke/trouble.nvim',
      requires = 'kyazdani42/nvim-web-devicons',
      config = function()
        require('user.req')('trouble', 'setup')
        require('user.util').lmap('e', '<cmd>TroubleToggle<cr>')
      end,
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
