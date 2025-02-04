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

autocmd('User', 'UiReady', function()
  autocmd('BufEnter', '*.*', function()
    -- show the current textwidth with color columns
    require('user.util').show_view_width()
  end)

  -- Show the view width when the UI is ready in case that event was emitted
  -- after a buffer had already been entered
  require('user.util').show_view_width()
end)

autocmd('BufReadPost', '*', function()
  -- make the buffer name a relative path
  vim.cmd('silent! lcd .')
end)

autocmd('VimResized', '*', function()
  -- automatically resize splits
  vim.api.nvim_command('wincmd =')

  -- show line numbers if the window is big enough
  vim.opt.number = vim.go.columns > 88
end)

-- make text files easier to work with
autocmd('FileType', 'text,textile,markdown,html', function()
  util.text_mode()
end)

-- disable yaml comment indent
autocmd('FileType', 'yaml', function()
  vim.cmd('set indentkeys-=0#"')
end)

-- better formatting for JavaScript
autocmd('FileType', 'javascript', function()
  vim.bo.formatprg = nil
  vim.bo.formatexpr = nil
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

local function bare_text()
  vim.wo.signcolumn = 'no'
  vim.wo.number = false
end

-- don't show number or sign column in popups, panes
autocmd('FileType', 'help', bare_text)

-- snacks sets the notification history filetype in a way that doesn't seem to
-- work well with FileType events
autocmd('BufEnter', '', function()
  if vim.o.filetype == 'snacks_notif_history' then
    bare_text()
  end
end)

-- close qf panes and help tabs with 'q'
autocmd('FileType', 'qf,help,fugitiveblame,lspinfo,startuptime', function()
  vim.keymap.set('', 'q', function()
    vim.api.nvim_buf_delete(0, {})
  end, { buffer = true })
end)

-- auto-set quickfix height
autocmd('FileType', 'qf', function()
  require('user.util').adjust_window_height(1, 10)
end)

-- q to close output panes
autocmd('BufEnter', 'output:///info', function()
  vim.keymap.set('', 'q', function()
    vim.api.nvim_buf_delete(0, {})
  end, { buffer = true })
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

-- autosave on exit
autocmd({ 'ExitPre' }, '*', function()
  vim.cmd('silent! wa')
end)
