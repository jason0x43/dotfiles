local packer = require('packer')

packer.startup({
  function(use)
    -- manage the package manager
    use('wbthomason/packer.nvim')

    -- plenary is a common dependency
    use({
      'nvim-lua/plenary.nvim',
      event = 'VimEnter',
    })

    -- devicons are needed by the status bar
    use({
      'kyazdani42/nvim-web-devicons',
      event = 'VimEnter',
    })

    -- flashy status bar
    use({
      'nvim-lualine/lualine.nvim',
      event = 'VimEnter',
      config = function()
        require('plugins.lualine')
      end,
    })

    -- tree
    use({
      'kyazdani42/nvim-tree.lua',
      -- nvim-tree needs to load at the same time or before a file is loaded for
      -- it to properly locate the file when initially showing the tree
      event = 'VimEnter',
      setup = function()
        -- append a slash to folder names
        vim.g.nvim_tree_add_trailing = 1

        -- close the tree after opening a file
        vim.g.nvim_tree_quit_on_open = 1

        -- ignore things
        vim.g.nvim_tree_ignore = { '.git', '.cache' }
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
      end,
    })

    -- autodetect buffer formatting
    use({
      'tpope/vim-sleuth',
      event = 'BufRead',
      config = function()
        -- Disable sleuth for markdown files as it slows the load time
        -- significantly
        vim.cmd('autocmd FileType markdown :let b:sleuth_automatic = 0')
      end,
    })

    -- Useful startup text, menu
    use({
      'mhinz/vim-startify',
      event = 'VimEnter',
      config = function()
        require('plugins.startify')
      end,
    })

    -- highlight color strings
    use({
      'norcalli/nvim-colorizer.lua',
      event = 'BufRead',
      config = function()
        require('colorizer').setup({ '*' }, {
          names = false,
        })
      end,
    })

    -- better start/end matching
    use({
      'andymass/vim-matchup',
      event = 'CursorMoved',
      config = function()
        vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      end,
    })

    -- preserve layout when closing buffers; used for <leader>k
    use({
      'moll/vim-bbye',
      cmd = 'Bdelete',
    })

    -- more efficient cursorhold behavior
    -- see https://github.com/neovim/neovim/issues/12587
    use({
      'antoinemadec/FixCursorHold.nvim',
      event = 'BufRead',
    })

    -- gc for commenting code blocks
    use({ 'tpope/vim-commentary', event = 'CursorMoved' })

    -- EditorConfig
    use({
      'editorconfig/editorconfig-vim',
      event = 'BufRead',
      setup = function()
        -- Don't let editorconfig set the max line -- it's handled via an
        -- autocommand
        vim.g.EditorConfig_max_line_indicator = 'none'
      end,
    })

    -- git utilities
    use({
      'tpope/vim-fugitive',
      cmd = 'Git',
    })

    -- support for repeating mapped commands
    use({
      'tpope/vim-repeat',
      event = 'CursorMoved',
    })

    -- for manipulating parens and such
    use({
      'tpope/vim-surround',
      event = 'CursorMoved',
    })

    -- easy vertical alignment of code elements
    use({
      'junegunn/vim-easy-align',
      cmd = 'EasyAlign',
    })

    -- visualize the undo tree
    use({
      'mbbill/undotree',
      cmd = 'UndotreeToggle',
      config = function()
        require('plugins.undotree')
      end,
    })

    -- for filetype features like syntax highlighting and indenting
    use({
      'nvim-treesitter/nvim-treesitter',
      event = 'BufRead',
      run = ':TSUpdate',
      config = function()
        require('plugins.nvim-treesitter')
      end,
    })

    -- provide TSHighlightCapturesUnderCursor command
    use({
      'nvim-treesitter/playground',
      after = 'nvim-treesitter',
    })

    -- set proper commentstring for embedded languages
    use({
      'JoosepAlviste/nvim-ts-context-commentstring',
      after = 'nvim-treesitter',
    })

    -- show semantic file location (e.g., what function you're in)
    use({
      'SmiteshP/nvim-gps',
      after = 'nvim-treesitter',
      config = function()
        require('nvim-gps').setup()
      end,
    })

    -- fuzzy finding
    use({
      'nvim-telescope/telescope.nvim',
      cmd = 'Telescope',
      setup = function()
        require('plugins.telescope').setup()
      end,
      config = function()
        require('plugins.telescope').config()
      end,
    })
    use({
      'nvim-telescope/telescope-fzf-native.nvim',
      after = 'telescope.nvim',
      run = 'make',
      config = function()
        require('telescope').load_extension('fzf')
      end,
    })
    use({
      'nvim-telescope/telescope-symbols.nvim',
      after = 'telescope.nvim',
    })

    -- easier movement between vim and tmux panes, and between vim panes
    use({
      'numToStr/Navigator.nvim',
      event = 'VimEnter',
      config = function()
        require('plugins.Navigator')
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
    use('vim-scripts/applescript.vim')
    use('vim-scripts/Textile-for-VIM')
    use({
      'mzlogin/vim-markdown-toc',
      cmd = { 'GenTocGFM', 'UpdateToc' },
      setup = function()
        vim.g.vmt_auto_update_on_save = 0
      end,
    })
    use({ 'tpope/vim-classpath', ft = { 'java' } })
    use('MaxMEllon/vim-jsx-pretty')
    use('pangloss/vim-javascript')

    -- native LSP
    use({
      'neovim/nvim-lspconfig',
      event = 'BufRead',
      config = function()
        require('lsp')
      end,
    })
    use({
      'jose-elias-alvarez/null-ls.nvim',
      after = { 'nvim-lspconfig', 'plenary.nvim' },
      config = function()
        require('plugins.null-ls')
      end,
    })
    use({
      'williamboman/nvim-lsp-installer',
      after = 'nvim-lspconfig',
      config = function()
        require('nvim-lsp-installer').on_server_ready(function(server)
          local config = require('lsp').get_lsp_config(server.name)
          server:setup(config)
          vim.cmd('do User LspAttachBuffers')
        end)

        require('util').cmd('LspStatus', 'LspInstallInfo')
      end,
    })
    use({
      'folke/trouble.nvim',
      cmd = 'Trouble',
      config = function()
        require('plugins.trouble')
      end,
    })
    use({
      -- 'arkav/lualine-lsp-progress',
      'clason/lualine-lsp-progress',
      branch = 'adapt-shadman',
      after = 'nvim-lspconfig',
    })
    use({
      'simrat39/symbols-outline.nvim',
      after = 'nvim-lspconfig',
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

    -- This is disabled right now because it conflicts with matchup's
    -- highlighting for function/end and if/end pairs.
    -- highlight current word
    -- use({
    --   'RRethy/vim-illuminate',
    --   after = 'nvim-lspconfig',
    --   setup = function()
    --     vim.g.Illuminate_highlightPriority = -10
    --   end,
    -- })

    -- better git diff views
    use({
      'sindrets/diffview.nvim',
      cmd = 'DiffviewOpen',
      config = function()
        require('diffview').setup()
      end,
    })

    -- better git decorations
    use({
      'lewis6991/gitsigns.nvim',
      after = 'plenary.nvim',
      config = function()
        require('gitsigns').setup({
          signs = {
            add = { text = '▋' },
            change = { text = '▋' },
          },
        })
      end,
    })

    use({
      'ms-jpq/coq_nvim',
      branch = 'coq',
      run = 'COQ',
      setup = function()
        vim.g.coq_settings = {
          auto_start = 'shut-up',
          ['display.icons.mode'] = 'none',
          ['display.pum.source_context'] = { '', '' },
        }
      end,
      requires = {
        { 'ms-jpq/coq.thirdparty', after = 'coq_nvim', branch = '3p' },
        { 'ms-jpq/coq.artifacts', after = 'coq_nvim', branch = 'artifacts' },
      },
    })

    -- startup time profiling
    use({ 'dstein64/vim-startuptime', cmd = 'StartupTime' })
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
