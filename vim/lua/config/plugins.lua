local plugins = {
  -- manage the package manager
  'savq/paq-nvim',

  -- Color schemes
  'jason0x43/nvim-base16.lua',

  -- Useful startup text, menu
  'mhinz/vim-startify',

  -- highlight color strings
  'norcalli/nvim-colorizer.lua',

  -- better start/end matching
  'andymass/vim-matchup',

  -- flashy status bar
  'hoob3rt/lualine.nvim',
  { 'kyazdani42/nvim-web-devicons', opt = true },

  -- preserve layout when closing buffers; used for <leader>k
  'moll/vim-bbye',

  -- more efficient cursorhold behavior
  'antoinemadec/FixCursorHold.nvim',

  -- gc for commenting code blocks
  'tpope/vim-commentary',

  -- EditorConfig
  'editorconfig/editorconfig-vim',

  -- git utilities
  'tpope/vim-fugitive',

  -- useful pairs of mappings
  'tpope/vim-unimpaired',

  -- support for repeating mapped commands
  'tpope/vim-repeat',

  -- for manipulating parens and such
  'tpope/vim-surround',

  -- easy vertical alignment of code elements
  'junegunn/vim-easy-align',

  -- visualize the undo tree
  'mbbill/undotree',

  -- render ANSI escape sequences
  'powerman/vim-plugin-AnsiEsc',

  -- support the jsonc filetype
  'neoclide/jsonc.vim',

  -- use treesitter for filetype handling
  { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
  'p00f/nvim-ts-rainbow',

  -- fuzzy finding
  { 'junegunn/fzf', run = vim.fn['fzf#install'] },
  'junegunn/fzf.vim',

  -- open files at the last edited position
  'farmergreg/vim-lastplace',

  -- tree
  'kyazdani42/nvim-tree.lua',

  -- highlight current word
  'RRethy/vim-illuminate'
}

local optional = {
  -- easier movement between vim and tmux panes
  { 'christoomey/vim-tmux-navigator', opt = true },

  -- show version info in package.json files
  { 'meain/vim-package-info', run = 'npm install', opt = true },

  -- filetype plugins
  { 'tpope/vim-markdown', opt = true },
  { 'vim-scripts/applescript.vim', opt = true },
  { 'vim-scripts/Textile-for-VIM', opt = true },
  { 'mzlogin/vim-markdown-toc', opt = true },
  { 'tpope/vim-classpath', opt = true },
  { 'lervag/vimtex', opt = true },

  -- native LSP
  { 'neovim/nvim-lspconfig', opt = true },
  { 'kabouzeid/nvim-lspinstall', opt = true },
  { 'hrsh7th/nvim-compe', opt = true },

  -- coc
  { 'neoclide/coc.nvim', run = 'yarn install --frozen-lockfile', opt = true },
  { 'antoinemadec/coc-fzf', opt = true }
}

require('paq')(vim.list_extend(plugins, optional))
