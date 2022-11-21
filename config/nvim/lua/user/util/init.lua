local M = {}
local fn = vim.fn

-- yank to terminal
-- https://sunaku.github.io/tmux-yank-osc52.html
function M.yank(text)
  local escape = fn.system('term_copy', text)
  if vim.v.shell_error == 1 then
    vim.cmd('echoerr ' .. escape)
  else
    fn.writefile({ escape }, '/dev/tty', 'b')
  end
end

-- map a key in a particular mode
--   mode - one or more mode characters
--   key  - the key to map
--   cmd  - the command to run for the key
--   opts - mapping options
--     noremap - if true, use a non-remappable mapping
--     silent  - if true, set the silent option
--     buffer  - a buffer number, or true for buffer 0
--     mode    - a mode; overrides the mode arg
local map_in_mode = function(mode, key, cmd, opts)
  local options = { noremap = true }
  local buf

  -- <plug> mappings won't work with noremap
  local cmd_lower = cmd:lower()
  if cmd_lower:find('<plug>') then
    options.noremap = nil
  end

  -- pull buffer out of opts if specified
  if opts and opts.buffer then
    buf = opts.buffer == true and 0 or opts.buffer
    opts.buffer = nil
  end

  -- pull mode out of opts if specified
  if opts and opts.mode then
    mode = opts.mode
    opts.mode = nil
  end

  -- add any remaining opts to options
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end

  -- get a referenced to a key mapper function; what is used depends on whether
  -- or not the map is being set for a specific buffer
  local set_keymap
  if buf then
    set_keymap = function(_mode, _key, _cmd, _options)
      vim.api.nvim_buf_set_keymap(buf, _mode, _key, _cmd, _options)
    end
  else
    set_keymap = vim.api.nvim_set_keymap
  end

  -- create a mapping for every mode in the mode string
  if mode == '' then
    set_keymap(mode, key, cmd, options)
  else
    mode:gsub('.', function(m)
      set_keymap(m, key, cmd, options)
    end)
  end
end

-- map a key in all modes
function M.map(key, cmd, opts)
  map_in_mode('', key, cmd, opts)
end

-- map a key in normal mode using the leader key
function M.lmap(key, cmd, opts)
  map_in_mode('n', '<leader>' .. key, cmd, opts)
end

-- map a key in insert mode using the leader key
function M.imap(key, cmd, opts)
  map_in_mode('i', key, cmd, opts)
end

-- map a key in s mode using the leader key
function M.smap(key, cmd, opts)
  map_in_mode('s', key, cmd, opts)
end

-- map a key in insert mode using the leader key
function M.nmap(key, cmd, opts)
  map_in_mode('n', key, cmd, opts)
end

-- create an augroup from a name and list of commands
-- commands are of the form
--   { group, definition }
function M.augroup(name, commands)
  vim.cmd('augroup ' .. name)
  vim.cmd('autocmd!')
  for _, def in ipairs(commands) do
    vim.cmd('autocmd ' .. def)
  end
  vim.cmd('augroup END')
end

-- create a vim command
function M.cmd(name, argsOrCmd, cmd)
  local args = cmd and argsOrCmd or nil
  cmd = cmd and cmd or argsOrCmd

  if args == nil then
    vim.cmd('command! ' .. name .. ' ' .. cmd)
  else
    vim.cmd('command! ' .. args .. ' ' .. name .. ' ' .. cmd)
  end
end

-- create a buffer-local vim command
function M.bufcmd(name, argsOrCmd, cmd)
  if not cmd then
    cmd = argsOrCmd
    argsOrCmd = '-buffer'
  else
    argsOrCmd = '-buffer ' .. argsOrCmd
  end

  M.cmd(name, argsOrCmd, cmd)
end

-- settings for text files
function M.text_mode()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.list = false
  vim.wo.signcolumn = 'no'

  M.map('k', 'gk', { buffer = true })
  M.map('j', 'gj', { buffer = true })
  M.map('$', 'g$', { buffer = true })
  M.map('^', 'g^', { buffer = true })
end

-- set colorcolumn to show the current textwidth
function M.show_view_width()
  local filetype = vim.bo.filetype
  local tw = vim.bo.textwidth

  if vim.wo.diff or filetype == 'help' or tw == 0 then
    vim.wo.colorcolumn = ''
  else
    vim.wo.colorcolumn = fn.join(fn.range(tw + 1, tw + 1 + vim.go.columns), ',')
  end
end

-- set window height within a min/max range
function M.adjust_window_height(minheight, maxheight)
  local line = fn.line('$')
  local val = fn.max({ fn.min({ line, maxheight }), minheight })
  vim.cmd(val .. 'wincmd _')
end

-- TS filetypes
M.ts_types = {
  'typescript',
  'typescript.jsx',
  'typescriptreact',
  'tsx',
  'javascript',
  'javascript.jsx',
  'javascriptreact',
  'jsx',
}

local ts_types_str

M.ts_types_str = function()
  if not ts_types_str then
    ts_types_str = table.concat(M.ts_types, ',')
  end
  return ts_types_str
end

-- restore the cursor position in a file
function M.restore_cursor()
  local filetype = vim.bo.filetype
  local buftype = vim.bo.buftype

  if
    buftype == 'nofile'
    or filetype:find('commit') ~= nil
    or filetype == 'svn'
  then
    return
  end

  local line = fn.line
  if line('\'"') >= 1 and line('\'"') <= line('$') then
    vim.cmd('normal! g`"zz')
  end
end

function M.print_syn_group()
  local ls = fn.synID(fn.line('.'), fn.col('.'), 1)
  if ls ~= 0 then
    print(
      fn.synIDattr(ls, 'name')
        .. ' -> '
        .. fn.synIDattr(fn.synIDtrans(ls), 'name')
    )
  else
    print('No highlight')
  end
end

function M.in_git_dir()
  vim.fn.system({ 'git', 'rev-parse', '--is-inside-work-tree' })
  return vim.v.shell_error == 0
end

function M.get_script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match('(.*/)')
end

return M
