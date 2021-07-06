require 'paq' {
	-- Always start -------------------------------

	-- manage the package manager
	'savq/paq-nvim';

	-- Color schemes
	'chriskempson/base16-vim';

	-- Useful startup text, menu
	'mhinz/vim-startify';

	-- better start/end matching
	'andymass/vim-matchup';

	-- flashy status bar
  'hoob3rt/lualine.nvim';
  { 'kyazdani42/nvim-web-devicons', opt = true };

	-- preserve layout when closing buffers; used for <leader>k
	'moll/vim-bbye';

	-- more efficient cursorhold behavior
	'antoinemadec/FixCursorHold.nvim';

	-- gc for commenting code blocks
	{ 'tpope/vim-commentary' };

	-- EditorConfig
	'editorconfig/editorconfig-vim';

	-- git utilities
	'tpope/vim-fugitive';

	-- useful pairs of mappings
	'tpope/vim-unimpaired';

	-- support for repeating mapped commands
	'tpope/vim-repeat';

	-- for manipulating parens and such
	'tpope/vim-surround';

	-- easy vertical alignment of code elements
	'junegunn/vim-easy-align';

	-- visualize the undo tree
	'mbbill/undotree';

	-- render ANSI escape sequences
	'powerman/vim-plugin-AnsiEsc';

	-- support the jsonc filetype
	'neoclide/jsonc.vim';

	-- completion
	{ 'neoclide/coc.nvim', run='yarn install --frozen-lockfile' };

	-- use treesitter for filetype handling
    { 'nvim-treesitter/nvim-treesitter', run=':TSUpdate' };

	-- fuzzy finding
	{ 'junegunn/fzf', run=vim.fn['fzf#install'] };
    'junegunn/fzf.vim';

	-- open files at the last edited position
	'farmergreg/vim-lastplace';

	-- Lazy loaded --------------------------------

	-- easier movement between vim and tmux panes
	{ 'christoomey/vim-tmux-navigator', opt=true };

	-- show version info in package.json files
	{ 'meain/vim-package-info', run='npm install', opt=true };

	-- filetype plugins
	{ 'tpope/vim-markdown', opt=true };
	{ 'vim-scripts/applescript.vim', opt=true };
	{ 'vim-scripts/Textile-for-VIM', opt=true };
	{ 'mzlogin/vim-markdown-toc', opt=true };
	{ 'tpope/vim-classpath', opt=true };
	{ 'lervag/vimtex', opt=true };
}
