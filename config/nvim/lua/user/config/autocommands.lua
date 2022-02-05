local util = require('user.util')

util.augroup('init_autocommands', {
  -- make text files easier to work with
  'FileType text,textile,markdown,html lua require("user.util").text_mode()',

  -- show the current textwidth
  'BufEnter *.* lua require("user.util").show_view_width()',

  -- automatically resize splits
  'VimResized * wincmd =',

  -- wrap lines in quickfix windows
  'FileType qf setlocal wrap linebreak nolist breakindent breakindentopt=shift:2 colorcolumn=""',

  -- don't use the colorcolumn in Trouble windows
  'FileType Trouble setlocal colorcolumn=""',

  -- don't show sign column in help panes
  'FileType help setlocal signcolumn=no',

  -- close qf panes and help tabs with 'q'
  'FileType qf,fugitiveblame,lspinfo,startuptime noremap <buffer> <silent> q :bd<CR>',
  'FileType help noremap <buffer> <silent> q :tabclose<CR>',
  'BufEnter output:///info nnoremap <buffer> <silent> q :bd<CR>',

  -- auto-set quickfix height
  'FileType qf lua require("user.util").adjust_window_height(1, 10)',

  -- identify filetypes
  'BufNewFile,BufRead .envrc setfiletype bash',
  'BufNewFile,BufRead fish_funced.* setfiletype fish',
  'BufNewFile,BufRead *.ejs setfiletype html',
  'BufNewFile,BufRead .{jscsrc,bowerrc,tslintrc,eslintrc,dojorc,prettierrc} setfiletype json',
  'BufNewFile,BufRead .dojorc-* setfiletype json',
  'BufNewFile,BufRead *.dashtoc setfiletype json',
  'BufNewFile,BufRead Podfile setfiletype ruby',
  'BufNewFile,BufRead */zsh/functions/* setfiletype zsh',
  'BufNewFile,BufRead {ts,js}config.json setfiletype jsonc',
  'BufNewFile,BufRead intern.json setfiletype jsonc',
  'BufNewFile,BufRead intern{-.}*.json setfiletype jsonc',
  'BufNewFile,BufRead *.textile setfiletype textile',

  -- highlight yanked text
  'TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}',

  -- restore cursor position when opening a file
  -- run this in BufWinEnter instead of BufReadPost so that this won't override
  -- a line number provided on the commandline
  'BufWinEnter * lua require("user.util").restore_cursor()',
})
