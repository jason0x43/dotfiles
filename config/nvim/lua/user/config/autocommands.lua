vim.api.nvim_create_augroup('init_autocmds', {})

local function autocmd(type, pattern, callback)
  vim.api.nvim_create_autocmd(type, {
    group = 'init_autocmds',
    pattern = pattern,
    callback = callback,
  })
end

-- Open files in readonly if they're already open instead of printing a huge
-- warning message
autocmd('SwapExists', '*', function(file)
  vim.v.swapchoice = 'o'
  vim.notify('Swap file exists for ' .. file, vim.log.levels.WARN)
end)

-- Make the buffer name a relative path
autocmd('BufReadPost', '*', function()
  vim.cmd('silent! lcd .')
end)

-- Update settings when the vim window is resized
autocmd('VimResized', '*', function()
  -- Automatically resize splits
  vim.api.nvim_command('wincmd =')

  -- Show line numbers if the window is big enough
  vim.o.number = vim.o.columns > 88
end)

-- Make text files easier to work with
autocmd('FileType', 'text,textile,markdown,html', function()
  vim.o.wrap = true
  vim.o.linebreak = true
  vim.o.list = false
  vim.o.signcolumn = 'no'

  -- Use visual movement instead of line based movement
  vim.keymap.set('', 'k', 'gk', { buffer = 0 })
  vim.keymap.set('', 'j', 'gj', { buffer = 0 })
  vim.keymap.set('', '$', 'g$', { buffer = 0 })
  vim.keymap.set('', '^', 'g^', { buffer = 0 })
end)

-- Disable yaml re-indent when commenting
autocmd('FileType', 'yaml', function()
  vim.opt.indentkeys = vim.opt.indentkeys - '0#'
end)

-- Wrap lines in quickfix windows
autocmd('FileType', 'qf', function()
  vim.o.wrap = true
  vim.o.linebreak = true
  vim.o.list = false
  vim.o.breakindent = false
  vim.o.breakindentopt = 'shift:2'
  vim.o.colorcolumn = ''
end)

---Remove extra information in a pane
local function bare_text()
  vim.wo.signcolumn = 'no'
  vim.wo.number = false
end

-- Don't show number or sign column in popups, panes
autocmd('FileType', 'help', bare_text)

-- No filetype event is emitted for Snacks notification history panes
autocmd('BufEnter', '', function()
  if vim.o.filetype == 'snacks_notif_history' then
    bare_text()
  end
end)

---Add a keymap to close the current window with 'q'
local function close_with_q()
  vim.keymap.set('', 'q', function()
    vim.api.nvim_buf_delete(0, {})
  end, { buffer = true })
end

-- Close certain information panes with 'q'
autocmd(
  'FileType',
  { 'qf', 'help', 'fugitiveblame', 'lspinfo', 'startuptime' },
  close_with_q
)

-- Auto-set quickfix height
autocmd('FileType', 'qf', function()
  local line = vim.fn.line('$')
  local val = vim.fn.max({ vim.fn.min({ line, 10 }), 1 })
  vim.cmd(val .. 'wincmd _')
end)

-- q to close output panes
autocmd('BufEnter', 'output:///info', close_with_q)

-- Highlight yanked text
autocmd('TextYankPost', '*', function()
  vim.highlight.on_yank({
    higroup = 'IncSearch',
    timeout = 150,
    on_visual = true,
  })
end)

-- Restore cursor position when opening a file.
-- Run this in BufWinEnter instead of BufReadPost so that this won't override a
-- line number provided on the commandline.
autocmd('BufWinEnter', '*', function()
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
end)

-- Autosave on exit
-- autocmd('QuitPre', '*', function()
--   local function some_is_modified()
--     for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--       if vim.api.nvim_get_option_value('modified', { buf = buf }) then
--         return true
--       end
--     end
--   end
--
--   if some_is_modified() then
--     local answer = vim.ui.input(
--       { prompt = 'Exit for real?' },
--       function(input)
--         print('user answered ' .. input)
--       end
--     )
--   end
--
--   -- vim.cmd('silent! wa')
-- end)
