local exports = {}

-- yank to terminal
-- https://sunaku.github.io/tmux-yank-osc52.html
function exports.yank(text)
  local escape = vim.fn.system('term_copy', text)
  if vim.v.shell_error == 1 then
    vim.cmd('echoerr ' .. escape)
  else
    vim.fn.writefile({ escape }, '/dev/tty', 'b')
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
  local options = { noremap = true, silent = true }
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
function exports.map(key, cmd, opts)
  map_in_mode('', key, cmd, opts)
end

-- map a key in normal mode using the leader key
function exports.lmap(key, cmd, opts)
  map_in_mode('n', '<leader>' .. key, cmd, opts)
end

-- map a key in insert mode using the leader key
function exports.imap(key, cmd, opts)
  map_in_mode('i', key, cmd, opts)
end

-- map a key in insert mode using the leader key
function exports.nmap(key, cmd, opts)
  map_in_mode('n', key, cmd, opts)
end

-- create an augroup from a name and list of commands
-- commands are of the form
--   { group, definition }
function exports.augroup(name, commands)
  vim.cmd('augroup ' .. name)
  vim.cmd('autocmd!')
  for _, def in ipairs(commands) do
    vim.cmd('autocmd ' .. def)
  end
  vim.cmd('augroup END')
end

-- create a vim command
function exports.cmd(name, argsOrCmd, cmd)
  local args = cmd and argsOrCmd or nil
  cmd = cmd and cmd or argsOrCmd

  if args == nil then
    vim.cmd('command! ' .. name .. ' ' .. cmd)
  else
    vim.cmd('command! ' .. args .. ' ' .. name .. ' ' .. cmd)
  end
end

-- settings for text files
function exports.text_mode()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.list = false
  vim.wo.signcolumn = 'no'
end

-- set colorcolumn to show the current textwidth
function exports.show_view_width()
  local tw = vim.bo.textwidth
  if tw and tw > 0 then
    vim.wo.colorcolumn = vim.fn.join(
      vim.fn.range(tw + 1, tw + 1 + vim.go.columns),
      ','
    )
  end
end

-- set window height within a min/max range
function exports.adjust_window_height(minheight, maxheight)
  local line = vim.fn.line('$')
  local val = vim.fn.max({ vim.fn.min({ line, maxheight }), minheight })
  vim.cmd(val .. 'wincmd _')
end

-- TS filetypes
exports.ts_types = {
  'typescript',
  'typescript.jsx',
  'typescriptreact',
  'javascript',
  'javascript.jsx',
  'javascriptreact',
}

-- restore the cursor position in a file
function exports.restore_cursor()
  local line = vim.fn.line
  if
    line('\'"') >= 1
    and line('\'"') <= line('$')
    and vim.bo.filetype:find('commit') == nil
  then
    vim.cmd('normal! g`"zz')
  end
end

return exports
