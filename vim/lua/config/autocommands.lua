local util = require('util')

util.augroup('init_autocommands', {
	-- make text files easier to work with
	'FileType text,textile,markdown,html call v:lua.util.text_mode()',

	-- show the current textwidth
	'BufEnter *.* call v:lua.util.show_view_width()',

	-- automatically resize splits
	'VimResized * wincmd =',

	-- wrap lines in quickfix windows
	'FileType qf setlocal wrap linebreak nolist breakindent'
	    .. ' breakindentopt=shift:2',

	-- close help files and qf panes with 'q' or Esc
	'FileType help,qf,fugitiveblame noremap <buffer> <silent> q :bd<CR>',
	'BufEnter output:///info nnoremap <buffer> <silent> q :bd<CR>',

	-- auto-close preview windows after autocomplete
	'CompleteDone * pclose',

	-- auto-set quickfix height
	'FileType qf call v:lua.util.adjust_window_height(1, 10)',

  -- apply customizations when the color scheme is updated
  'ColorScheme * call v:lua.theme.base16_customize()',
})
