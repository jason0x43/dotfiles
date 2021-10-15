local packer = require('packer')

packer.startup({
  function(use)
    use('lewis6991/impatient.nvim')

    -- manage the package manager
    use('wbthomason/packer.nvim')

    -- plenary is a common dependency
    use({
      'nvim-lua/plenary.nvim',
      event = { 'BufEnter', 'VimEnter' },
    })

    -- devicons are needed by the status bar
    use({
      'kyazdani42/nvim-web-devicons',
      event = 'VimEnter',
    })

    -- flashy status bar
    use({
      'shadmansaleh/lualine.nvim',
      after = 'nvim-web-devicons',
      config = function()
        require('plugins.lualine')
      end,
    })

    -- tree
    use({
      'kyazdani42/nvim-tree.lua',
      -- nvim-tree needs to load at the same time or before a file is loaded for
      -- it to properly locate the file when initially showing the tree
      after = 'nvim-web-devicons',
      config = function()
        require('plugins.nvim-tree')
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
    use({ 'tpope/vim-commentary', event = 'BufRead' })

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

    -- support the jsonc filetype
    use({
      'neoclide/jsonc.vim',
      event = 'VimEnter',
    })

    -- use treesitter for filetype handling
    use({
      'nvim-treesitter/nvim-treesitter',
      event = 'BufRead',
      run = ':TSUpdate',
      config = function()
        require('plugins.nvim-treesitter')
      end,
    })
    use({
      'nvim-treesitter/playground',
      after = 'nvim-treesitter'
    })

    -- fuzzy finding
    use({
      'nvim-telescope/telescope.nvim',
      cmd = 'Telescope',
      setup = function ()
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
      ft = { 'markdown' },
      setup = function()
        vim.g.markdown_fenced_languages = {
          'css',
          'html',
          'javascript',
          'typescript',
          'js=javascript',
          'ts=typescript',
        }
      end
    })
    use({ 'vim-scripts/applescript.vim', ft = { 'applescript' } })
    use({ 'vim-scripts/Textile-for-VIM', ft = { 'textile' } })
    use({
      'mzlogin/vim-markdown-toc',
      ft = { 'markdown' },
      setup = function()
        vim.g.vmt_auto_update_on_save = 0
      end,
    })
    use({ 'tpope/vim-classpath', ft = { 'java' } })
    use({ 'MaxMEllon/vim-jsx-pretty', ft = require('util').ts_types })

    -- completion
    -- use({
    --   'L3MON4D3/LuaSnip',
    --   event = 'BufRead',
    -- })
    -- use({
    --   'hrsh7th/nvim-cmp',
    --   after = { 'LuaSnip', 'plenary.nvim' },
    --   requires = {
    --     { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
    --     { 'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp' },
    --     { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
    --     { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
    --   },
    --   config = function()
    --     require('plugins.nvim-cmp')
    --   end,
    -- })

    -- native LSP
    use({
      'neovim/nvim-lspconfig',
      -- after = 'cmp-nvim-lsp',
      event = 'BufRead',
      config = function()
        require('lsp')
      end,
    })
    use({
      'jose-elias-alvarez/nvim-lsp-ts-utils',
      after = 'nvim-lspconfig',
    })
    use({
      'jose-elias-alvarez/null-ls.nvim',
      after = { 'nvim-lspconfig', 'plenary.nvim' },
      config = function()
        require('plugins.null-ls')
      end,
    })
    use({
      'kabouzeid/nvim-lspinstall',
      after = 'nvim-lspconfig',
      config = function()
        require('plugins.nvim-lspinstall')
      end,
    })
    use({
      'ray-x/lsp_signature.nvim',
      disable = true,
      after = 'nvim-lspconfig',
    })
    use({
      'folke/trouble.nvim',
      after = 'nvim-lspconfig',
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
            delete = { text = '▃' },
          }
        })
      end,
    })

    -- git UI
    use({
      'TimUntersberger/neogit',
      cmd = 'Neogit',
      config = function()
        require('plugins.neogit')
      end,
    })

    -- startup time profiling
    use({ 'dstein64/vim-startuptime', cmd = 'StartupTime' })

    -- show indents
    use({
      'lukas-reineke/indent-blankline.nvim',
      event = 'BufRead',
      setup = function()
        vim.g.indent_blankline_char = '│'
        vim.g.indent_blankline_enabled = false
      end,
    })

    -- indent and syntax
    -- use({
    --   'sheerun/vim-polyglot',
    --   event = 'BufEnter',
    --   disable = true,
    --   setup = function()
    --     -- Disable some polyglot options
    --     vim.g.polyglot_disabled = { 'autoindent', 'ftdetect' }
    --   end,
    -- })
  end,

  config = {
    display = {
      open_fn = function()
        -- show packer output in a float
        return require('packer.util').float({ border = 'rounded' })
      end,
    },
    -- Store the compiled file in the lua dir so impatient.nvim can cache it
    compile_path = vim.fn.stdpath('config') .. '/lua/packer_compiled.lua',
  },
})

return packer
