local util = require('util')
local fn = vim.fn

-- bootstrap packer
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_exists = fn.isdirectory(install_path) ~= 0
if not packer_exists then
  fn.system({
    'git',
    'clone',
    'git@github.com:wbthomason/packer.nvim',
    install_path,
  })
  vim.cmd('packadd packer.nvim')
  require('packer').init()
end

-- recompile the packer config whenever this file is edited
util.augroup(
  'init_packer',
  { 'BufWritePost */plugins/init.lua source <afile> | PackerCompile' }
)

require('packer').startup({
  function(use)
    -- manage the package manager
    use('wbthomason/packer.nvim')

    -- Useful startup text, menu
    use({
      'mhinz/vim-startify',
      config = function()
        require('plugins.startify')
      end,
    })

    -- highlight color strings
    use({
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('colorizer').setup({})
      end,
    })

    -- better start/end matching
    use('andymass/vim-matchup')

    -- preserve layout when closing buffers; used for <leader>k
    use({
      'moll/vim-bbye',
      config = function()
        require('plugins.vim-bbye')
      end,
    })

    -- more efficient cursorhold behavior
    -- see https://github.com/neovim/neovim/issues/12587
    use('antoinemadec/FixCursorHold.nvim')

    -- gc for commenting code blocks
    use('tpope/vim-commentary')

    -- EditorConfig
    use('editorconfig/editorconfig-vim')

    -- git utilities
    use('tpope/vim-fugitive')

    -- useful pairs of mappings
    use('tpope/vim-unimpaired')

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
        require('plugins.undotree')
      end,
    })

    -- render ANSI escape sequences
    -- use('powerman/vim-plugin-AnsiEsc')

    -- support the jsonc filetype
    use('neoclide/jsonc.vim')

    -- use treesitter for filetype handling
    use({
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = function()
        require('config.treesitter')
      end,
    })

    -- fuzzy finding
    use({
      'nvim-telescope/telescope.nvim',
      requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-fzy-native.nvim',
        'nvim-telescope/telescope-symbols.nvim',
        {
          'nvim-telescope/telescope-frecency.nvim',
          requires = 'tami5/sql.nvim',
        },
      },
      config = function()
        require('plugins.telescope')
      end,
    })

    -- tree
    use({
      'kyazdani42/nvim-tree.lua',
      config = function()
        require('plugins.nvim-tree')
      end,
    })

    -- highlight current word
    use({
      'RRethy/vim-illuminate',
      config = function()
        require('plugins.illuminate')
      end,
    })

    -- easier movement between vim and tmux panes, and between vim panes
    use({
      'numToStr/Navigator.nvim',
      config = function()
        require('plugins.Navigator')
      end,
    })

    -- filetype plugins
    use({ 'tpope/vim-markdown', opt = true, ft = { 'markdown' } })
    use({ 'vim-scripts/applescript.vim', opt = true, ft = { 'applescript' } })
    use({ 'vim-scripts/Textile-for-VIM', opt = true, ft = { 'textile' } })
    use({ 'mzlogin/vim-markdown-toc', opt = true, ft = { 'markdown' } })
    use({ 'tpope/vim-classpath', opt = true, ft = { 'java' } })
    use({ 'lervag/vimtex', opt = true, ft = { 'tex', 'latex' } })

    -- native LSP
    use({
      'neovim/nvim-lspconfig',
      requires = {
        'kabouzeid/nvim-lspinstall',
        'hrsh7th/nvim-compe',
        'folke/trouble.nvim',
        {
          'jose-elias-alvarez/null-ls.nvim',
          requires = 'nvim-lua/plenary.nvim',
        },
        'jose-elias-alvarez/nvim-lsp-ts-utils',
      },
      config = function()
        -- null-ls adds itself to lspconfig, so it needs to be setup before
        -- general LSP setup
        require('plugins.null-ls')
        require('lsp')
        require('plugins.nvim-lspinstall')
        require('plugins.nvim-compe')
        require('plugins.trouble')
      end,
    })

    -- flashy status bar
    use({
      'hoob3rt/lualine.nvim',
      requires = {
        'kyazdani42/nvim-web-devicons',
        'arkav/lualine-lsp-progress',
      },
      config = function()
        require('plugins.lualine')
      end,
    })

    -- better git diff views
    use({
      'sindrets/diffview.nvim',
      config = function()
        require('diffview').setup()
      end,
    })

    -- allow Deno for plugins
    use('vim-denops/denops.vim')

    -- better git decorations
    use({
      'lewis6991/gitsigns.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
      },
      config = function()
        require('gitsigns').setup()
      end,
    })

    -- git UI
    use({
      'TimUntersberger/neogit',
      config = function()
        require('plugins.neogit')
      end,
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

if not packer_exists then
  vim.cmd('PackerInstall')
end
