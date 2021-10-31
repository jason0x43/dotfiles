local packer = require('packer')

packer.startup({
  function(use)
    -- manage the package manager
    use('wbthomason/packer.nvim')

    -- speed up the lua loader
    use('lewis6991/impatient.nvim')

    -- plenary is a common dependency
    use('nvim-lua/plenary.nvim')

    -- devicons are needed by the status bar
    use('kyazdani42/nvim-web-devicons')

    -- flashy status bar
    use({
      'nvim-lualine/lualine.nvim',
      config = function()
        require('plugins.lualine_cfg')
      end,
      requires = {
        {
          -- 'arkav/lualine-lsp-progress',
          'clason/lualine-lsp-progress',
          branch = 'adapt-shadman',
        },
      },
    })

    -- file explorer in sidebar
    use({
      'kyazdani42/nvim-tree.lua',
      -- nvim-tree needs to load at the same time or before a file is loaded for
      -- it to properly locate the file when initially showing the tree
      setup = function()
        -- append a slash to folder names
        vim.g.nvim_tree_add_trailing = 1

        -- close the tree after opening a file
        vim.g.nvim_tree_quit_on_open = 1

        -- ignore things
        vim.g.nvim_tree_gitignore = 1
      end,
      config = function()
        require('nvim-tree').setup({
          update_focused_file = {
            enable = true,
          },
          view = {
            side = 'right',
            width = 40,
          },
        })

        require('util').lmap('n', '<cmd>NvimTreeToggle<cr>')
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
      'mhinz/vim-startify',
      config = function()
        local g = vim.g
        g.startify_session_persistence = 0
        g.startify_relative_path = 1
        g.startify_use_env = 1
        g.startify_files_number = 5
        g.startify_change_to_dir = 0
        g.startify_ascii_header = {
          ' ____ ____ ____ ____ ____ ____ ',
          '||n |||e |||o |||v |||i |||m ||',
          '||__|||__|||__|||__|||__|||__||',
          '|/__\\|/__\\|/__\\|/__\\|/__\\|/__\\|',
          '',
        }
        g.startify_custom_header = 'startify#pad(g:startify_ascii_header)'
        g.startify_lists = {
          { header = { '   MRU ' .. vim.fn.getcwd() }, type = 'dir' },
          { header = { '   MRU' }, type = 'files' },
        }

        require('util').lmap('s', '<cmd>Startify<cr>')
      end,
    })

    -- highlight color strings
    use({
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('colorizer').setup({ '*' }, {
          names = false,
        })
      end,
    })

    -- better start/end matching
    use({
      'andymass/vim-matchup',
      config = function()
        vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      end,
    })

    -- preserve layout when closing buffers; used for <leader>k
    use({
      'moll/vim-bbye',
      config = function()
        local util = require('util')
        util.lmap('k', '<cmd>Bdelete<cr>')
        util.lmap('K', '<cmd>Bdelete!<cr>')
      end
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

        require('util').lmap('u', '<cmd>UndotreeToggle<cr>')
      end,
    })

    -- for filetype features like syntax highlighting and indenting
    use({
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = function()
        require('plugins.nvim-treesitter_cfg')
      end,
      requires = {
        -- provide TSHighlightCapturesUnderCursor command
        'nvim-treesitter/playground',
        -- set proper commentstring for embedded languages
        'JoosepAlviste/nvim-ts-context-commentstring',
        -- show semantic file location (e.g., what function you're in)
        {
          'SmiteshP/nvim-gps',
          config = function()
            require('nvim-gps').setup()
          end,
        },
      },
    })

    -- fuzzy finding
    use({
      'nvim-telescope/telescope.nvim',
      setup = function()
        require('plugins.telescope_cfg').setup()
      end,
      config = function()
        require('plugins.telescope_cfg').config()
      end,
      requires = {
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          run = 'make',
          config = function()
            require('telescope').load_extension('fzf')
          end,
        },
        'nvim-telescope/telescope-symbols.nvim',
      },
    })

    -- easier movement between vim and tmux panes, and between vim panes
    use({
      'numToStr/Navigator.nvim',
      config = function()
        require('Navigator').setup()

        local util = require('util')
        util.nmap('<C-j>', '<cmd>lua require("Navigator").down()<cr>')
        util.nmap('<C-h>', '<cmd>lua require("Navigator").left()<cr>')
        util.nmap('<C-k>', '<cmd>lua require("Navigator").up()<cr>')
        util.nmap('<C-l>', '<cmd>lua require("Navigator").right()<cr>')
      end,
    })

    -- filetype plugins
    use({
      'tpope/vim-markdown',
      setup = function()
        vim.g.markdown_fenced_languages = {
          'css',
          'html',
          'javascript',
          'typescript',
          'js=javascript',
          'ts=typescript',
        }
      end,
    })
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
      config = function()
        require('lsp')
      end,
      requires = {
        {
          'jose-elias-alvarez/null-ls.nvim',
          config = function()
            require('plugins.null-ls_cfg')
          end,
        },
        {
          'williamboman/nvim-lsp-installer',
          config = function()
            require('nvim-lsp-installer').on_server_ready(function(server)
              local config = require('lsp').get_lsp_config(server.name)
              server:setup(config)
              vim.cmd('doautoall FileType')
            end)

            require('util').cmd('LspStatus', 'LspInstallInfo')
          end,
        },
      },
    })

    -- show buffer symbols, functions, etc in sidebar
    use({
      'simrat39/symbols-outline.nvim',
      setup = function()
        vim.g.symbols_outline = {
          auto_preview = false,
          width = 30,
        }
      end,
      config = function()
        local util = require('util')
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
      config = function()
        require('diffview').setup()
      end,
    })

    -- better git decorations
    use({
      'lewis6991/gitsigns.nvim',
      config = function()
        require('gitsigns').setup({
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
      -- disabled in favor of coq
      disable = true,
      config = function()
        require('plugins.nvim-cmp_cfg')
      end,
      requires = {
        'L3MON4D3/LuaSnip',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-nvim-lsp',
        'saadparwaiz1/cmp_luasnip',
      },
    })

    -- completion
    use({
      'ms-jpq/coq_nvim',
      branch = 'coq',
      run = ':COQdeps',
      setup = function()
        vim.g.coq_settings = {
          auto_start = 'shut-up',
          display = {
            icons = { mode = 'none' },
            ghost_text = { enabled = false },
            pum = { source_context = { '', '' } },
            preview = {
              positions = {
                north = 0,
                south = 0,
                west = 0,
                east = 0,
              },
            },
          },
        }
      end,
      requires = {
        { 'ms-jpq/coq.thirdparty', branch = '3p' },
        { 'ms-jpq/coq.artifacts', branch = 'artifacts' },
      },
    })

    -- startup time profiling
    use('dstein64/vim-startuptime')
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
