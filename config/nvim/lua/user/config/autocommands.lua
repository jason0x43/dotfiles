local util = require('user.util')

vim.api.nvim_create_augroup('init_autocmds', {})

local function autocmd(type, pattern, callback)
  vim.api.nvim_create_autocmd(type, {
    group = 'init_autocmds',
    pattern = pattern,
    callback = callback,
  })
end

-- open files in readonly if they're already open instead of printing a huge
-- warning message
autocmd('SwapExists', '*', function()
  vim.v.swapchoice = 'o'
end)

-- make text files easier to work with
autocmd('FileType', 'text,textile,markdown,html', function()
  util.text_mode()
end)

-- better formatting for JavaScript
autocmd('FileType', 'javascript', function()
  vim.bo.formatprg = nil
  vim.bo.formatexpr = nil
end)

autocmd('BufEnter', '*.*', function()
  -- show the current textwidth with color columns
  require('user.util').show_view_width()
end)

autocmd('VimResized', '*', function()
  -- automatically resize splits
  vim.api.nvim_command('wincmd =')

  -- show line numbers if the window is big enough
  vim.opt.number = vim.go.columns > 88
end)

-- wrap lines in quickfix windows
autocmd('FileType', 'qf', function()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.list = false
  vim.wo.breakindent = false
  vim.wo.breakindentopt = 'shift:2'
  vim.wo.colorcolumn = ''
end)

-- don't use the colorcolumn in Trouble windows
autocmd('FileType', 'Trouble', function()
  vim.wo.colorcolumn = ''
end)

-- don't show sign column in help panes
autocmd('FileType', 'help', function()
  vim.wo.signcolumn = 'no'
end)

-- close qf panes and help tabs with 'q'
autocmd('FileType', 'qf,fugitiveblame,lspinfo,startuptime', function()
  vim.keymap.set('', 'q', function()
    vim.api.nvim_buf_delete(0, {})
  end, { buffer = true })
end)
autocmd('FileType', 'help', function()
  vim.keymap.set('', 'q', function()
    vim.api.nvim_win_close(0, true)
  end, { buffer = true })
end)
autocmd('BufEnter', 'output:///info', function()
  vim.keymap.set('', 'q', function()
    vim.api.nvim_buf_delete(0, {})
  end, { buffer = true })
end)

-- auto-set quickfix height
autocmd('FileType', 'qf', function()
  require('user.util').adjust_window_height(1, 10)
end)

-- highlight yanked text
autocmd('TextYankPost', '*', function()
  vim.highlight.on_yank({
    higroup = 'IncSearch',
    timeout = 150,
    on_visual = true,
  })
end)

-- restore cursor position when opening a file
-- run this in BufWinEnter instead of BufReadPost so that this won't override
-- a line number provided on the commandline
autocmd('BufWinEnter', '*', function()
  require('user.util').restore_cursor()
end)

-- set filetypes
local function autoft(pattern, filetype)
  autocmd({ 'BufNewFile', 'BufRead' }, pattern, function()
    vim.bo.filetype = filetype
  end)
end

autoft('.envrc', 'bash')
autoft('fish_funced.*', 'fish')
autoft('*.ejs', 'html')
autoft('.{jscsrc,bowerrc,tslintrc,eslintrc,dojorc,prettierrc}', 'json')
autoft('.dojorc-*', 'json')
autoft('*.dashtoc', 'json')
autoft('Podfile', 'ruby')
autoft('*/zsh/functions/*', 'zsh')
autoft('{ts,js}config.json', 'jsonc')
autoft('intern.json', 'jsonc')
autoft('intern{-.}*.json', 'jsonc')
autoft('*.textile', 'textile')
autoft('*.{frag,vert}', 'glsl')

-- improve handling of very large files
autocmd({ 'BufReadPost', 'FileReadPost' }, '*', function()
  if require('user.util').is_large_file() then
    vim.bo.filetype = nil
    vim.bo.swapfile = false
    vim.bo.undofile = false
    vim.wo.foldmethod = 'manual'
  end
end)

-- show line numbers if the window is big enough
autocmd('VimResized', '*', function()
  vim.wo.number = vim.go.columns > 88
end)
