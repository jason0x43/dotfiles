vim.api.nvim_create_augroup('init_autocmds', {})

local group = 'init_autocmds'

-- Squelch warning warning message when opening files with swapfiles
vim.api.nvim_create_autocmd('SwapExists', {
  pattern = '*',
  group = group,
  callback = function(event)
    if vim.fn.getftime(vim.v.swapname) < vim.fn.getftime(event.file) then
      -- 	Swapfile is older than file itself -- delete it
      vim.fn.delete(vim.v.swapname)
      vim.notify('Deleted old swapfile', vim.log.levels.INFO)
      vim.v.swapchoice = 'e'
    else
      -- Open in read-only mode
      vim.notify('Swap file exists', vim.log.levels.WARN)
      vim.v.swapchoice = 'o'
    end
  end,
  desc = 'Open files in readonly if a swapfile exists',
})

-- Make the buffer name a relative path
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*',
  group = group,
  callback = function()
    vim.cmd('silent! lcd .')
  end,
  desc = "Make buffer's name a relative path",
})

-- Update settings when the vim window is resized
vim.api.nvim_create_autocmd('VimResized', {
  pattern = '*',
  group = group,
  callback = function()
    -- Automatically resize splits
    vim.api.nvim_command('wincmd =')

    -- Show line numbers if the window is big enough
    if vim.bo.buftype ~= 'nofile' then
      vim.o.number = vim.o.columns > 88
    end
  end,
  desc = 'Update settings when vim window is resized',
})

-- Make text files easier to work with
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'text', 'textile', 'markdown', 'html' },
  group = group,
  callback = function()
    vim.o.wrap = true
    vim.o.linebreak = true
    vim.o.list = false
    vim.o.signcolumn = 'no'

    -- Use visual movement instead of line based movement
    vim.keymap.set(
      '',
      'k',
      'gk',
      { buffer = 0, desc = 'Move up one visual line' }
    )
    vim.keymap.set(
      '',
      'j',
      'gj',
      { buffer = 0, desc = 'Move down one visual line' }
    )
    vim.keymap.set(
      '',
      '$',
      'g$',
      { buffer = 0, desc = 'Move to the end of the visible line' }
    )
    vim.keymap.set(
      '',
      '^',
      'g^',
      { buffer = 0, desc = 'Move to the start of the visible line' }
    )
  end,
  desc = 'Improved text file handling',
})

-- Disable yaml re-indent when commenting
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'yaml',
  group = group,
  callback = function()
    vim.opt.indentkeys = vim.opt.indentkeys - '0#'
  end,
  desc = 'Disable re-indent when commenting yaml lines',
})

---Remove extra information in a pane
local function bare_text()
  vim.bo.readonly = true
  vim.o.signcolumn = 'no'
  vim.o.number = false
  vim.o.colorcolumn = ''
end

-- Wrap lines in quickfix windows
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  group = group,
  callback = function()
    bare_text()
    vim.o.wrap = true
    vim.o.linebreak = true
    vim.o.list = false
    vim.o.breakindent = false
    vim.o.breakindentopt = 'shift:2'

    -- Cap window height
    local line = vim.fn.line('$')
    local val = vim.fn.max({ vim.fn.min({ line, 10 }), 1 })
    vim.cmd(val .. 'wincmd _')
  end,
  desc = 'Formatting for quickfix windows',
})

-- Don't show number or sign column in popups, panes
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'help', 'checkhealth' },
  group = group,
  callback = bare_text,
  desc = 'Use basic text display in system info panes',
})

-- No filetype event is emitted for Snacks notification history panes
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '',
  group = group,
  callback = function()
    if vim.o.filetype == 'snacks_notif_history' then
      bare_text()
    end
  end,
  desc = 'Use basic text display in Snacks notify history',
})

---Add a keymap to close the current window with 'q'
local function close_with_q()
  vim.keymap.set('', 'q', function()
    vim.api.nvim_win_close(0, false)
  end, { buffer = true, desc = 'Close the current pane' })
  vim.keymap.set('', '<esc>', function()
    vim.api.nvim_win_close(0, false)
  end, { buffer = true, desc = 'Close the current pane' })
end

-- Close certain information panes with 'q'
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'qf',
    'help',
    'fugitiveblame',
    'lspinfo',
    'startuptime',
    'messages',
  },
  group = group,
  callback = close_with_q,
  desc = 'Close system panes with q and esc',
})

-- q to close output panes
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'output:///info',
  group = group,
  callback = close_with_q,
  desc = 'Close system panes with q and esc',
})

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  pattern = '*',
  group = group,
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 150,
      on_visual = true,
    })
  end,
  desc = "Highlight text when it's yanked",
})

-- Restore cursor position when opening a file.
-- Run this in BufWinEnter instead of BufReadPost so that this won't override a
-- line number provided on the commandline.
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  group = group,
  callback = function()
    local filetype = vim.bo.filetype
    local buftype = vim.bo.buftype

    if
      buftype == 'nofile'
      or filetype:find('commit') ~= nil
      or filetype == 'svn'
    then
      return
    end

    local line = vim.fn.line
    if line('\'"') >= 1 and line('\'"') <= line('$') then
      vim.cmd('normal! g`"zz')
    end
  end,
  desc = 'Restore cursor position when opening a file',
})

-- Convenience behavior for MiniGit buffers
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'git',
  group = group,
  callback = function()
    bare_text()
    close_with_q()

    vim.keymap.set('', '<enter>', function()
      require('mini.git').show_at_cursor()
    end, { buffer = true, desc = 'Show git information for the cursor' })
  end,
  desc = 'Setup MiniGit output buffers',
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'kitty',
  callback = function()
    vim.go.laststatus = 0
    vim.wo.winbar = 'Scrollback'
    require('user.terminal').colorize()
    vim.defer_fn(function()
      vim.cmd('normal! 0')
    end, 100)
  end,
})
