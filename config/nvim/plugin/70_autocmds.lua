-- Squelch warning warning message when opening files with swapfiles
_G.Config.new_autocmd('SwapExists', '*', function(event)
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
end, 'Open files in readonly if a swapfile exists')

-- Update settings when the vim window is resized
_G.Config.new_autocmd('VimResized', '*', function()
  -- Automatically resize splits
  vim.api.nvim_command('wincmd =')

  -- Show line numbers if the window is big enough
  if vim.bo.buftype ~= 'nofile' and vim.bo.buftype ~= 'scrollback' then
    vim.o.number = vim.o.columns > 88
  end
end, 'Update settings when vim window is resized')

-- Make text files easier to work with
_G.Config.new_autocmd(
  'FileType',
  { 'text', 'textile', 'markdown', 'html' },
  function()
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
  'Improved text file handling'
)

-- Disable yaml re-indent when commenting
_G.Config.new_autocmd('FileType', 'yaml', function()
  vim.opt.indentkeys = vim.opt.indentkeys - '0#'
end, 'Disable re-indent when commenting yaml lines')

---Remove extra information in a pane
local function bare_text()
  vim.bo.readonly = true
  vim.o.signcolumn = 'no'
  vim.o.number = false
  vim.o.colorcolumn = ''
end

-- Wrap lines in quickfix windows
_G.Config.new_autocmd('FileType', 'qf', function()
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
end, 'Formatting for quickfix windows')

-- Don't show number or sign column in popups, panes
_G.Config.new_autocmd(
  'FileType',
  { 'help', 'checkhealth' },
  bare_text,
  'Use basic text display in system info panes'
)

-- No filetype event is emitted for Snacks notification history panes
_G.Config.new_autocmd('BufEnter', '', function()
  if vim.o.filetype == 'snacks_notif_history' then
    bare_text()
  end
end, 'Use basic text display in Snacks notify history')

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
_G.Config.new_autocmd('FileType', {
  'qf',
  'help',
  'fugitiveblame',
  'lspinfo',
  'startuptime',
  'messages',
}, close_with_q, 'Close system panes with q and esc')

-- q to close output panes
_G.Config.new_autocmd(
  'BufEnter',
  'output:///info',
  close_with_q,
  'Close system panes with q and esc'
)

-- Highlight yanked text
_G.Config.new_autocmd('TextYankPost', '*', function()
  vim.highlight.on_yank({
    higroup = 'IncSearch',
    timeout = 150,
    on_visual = true,
  })
end, "Highlight text when it's yanked")

-- Restore cursor position when opening a file.
-- Run this in BufWinEnter instead of BufReadPost so that this won't override a
-- line number provided on the commandline.
_G.Config.new_autocmd('BufWinEnter', '*', function()
  local filetype = vim.bo.filetype
  local buftype = vim.bo.buftype

  if
    buftype == 'nofile'
    or buftype == 'scrollback'
    or filetype:find('commit') ~= nil
    or filetype == 'svn'
  then
    return
  end

  local line = vim.fn.line
  if line('\'"') >= 1 and line('\'"') <= line('$') then
    vim.cmd('normal! g`"zz')
  end
end, 'Restore cursor position when opening a file')

-- Convenience behavior for MiniGit buffers
_G.Config.new_autocmd('FileType', 'git', function()
  bare_text()
  close_with_q()

  vim.keymap.set('', '<enter>', function()
    require('mini.git').show_at_cursor()
  end, { buffer = true, desc = 'Show git information for the cursor' })
end, 'Setup MiniGit output buffers')

-- Close mininotify history panes with 'q'
_G.Config.new_autocmd('FileType', 'mininotify-history', function()
  vim.keymap.set('', 'q', function()
    MiniBufremove.delete(0, true)
  end, { buffer = true, desc = 'Close the current window' })
end, 'Close notify history panes with q')

-- Setup buffers for Ghostty scrollback content
_G.Config.new_autocmd('FileType', 'scrollback', function()
  -- No line numbering
  vim.wo.number = false
  vim.bo.readonly = true

  -- Make 'q' quit
  vim.keymap.set({ 'n', 'v' }, 'q', '<cmd>qa!<cr>', { silent = true })

  -- Make '/' search backward
  vim.keymap.set('n', '/', '?', { noremap = true })

  -- Don't try leave a scroll margin around the cursor
  vim.opt_local.scrolloff = 0
  vim.opt_local.sidescrolloff = 0

  -- Disable all language servers
  vim.lsp.enable(vim.tbl_keys(vim.lsp._enabled_configs), false)

  vim.g.ministatusline_disable = true
  vim.o.laststatus = 0

  -- Scroll to the bottom of the file
  vim.schedule(function()
    vim.cmd('normal! G')
  end)

  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      -- Exit after yank to return to the terminal
      vim.defer_fn(function()
        vim.cmd('qa!')
      end, 220)
    end,
  })
end, 'Configure Ghostty scrollback buffers')
