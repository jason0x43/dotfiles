_G.util = {}
local util = _G.util

-- the user's home directory
util.home = os.getenv('HOME')

-- the local nvim data directory
util.data_home = os.getenv('XDG_DATA_HOME') or (util.home .. '/.local/share')

-- if we're in a repo, find the project root
util.project_root = vim.trim(vim.fn.system(
  'git rev-parse --show-toplevel 2> /dev/null'
))

-- check if a file exists
function util.file_exists(file)
	local f = io.open(file, 'rb')
	if f then
		f:close()
	end
	return f ~= nil
end

-- yank to terminal
-- https://sunaku.github.io/tmux-yank-osc52.html
function util.yank(text)
  print('yanking')
	local escape = vim.fn.system('term_copy', text)
	if vim.v.shell_error == 1 then
		vim.cmd('echoerr ' .. escape)
	else
		vim.fn.writefile({ escape }, '/dev/tty', 'b')
	end
end

util.keys = {}

-- map a key in a particular mode
--   mode - one or more mode characters
--   key  - the key to map
--   cmd  - the command to run for the key
--   opts - mapping options
--     noremap - if true, use a non-remappable mapping
--     silent  - if true, set the silent option
--     buffer  - a buffer number, or true for buffer 0
--     mode    - a mode; overrides the mode arg
local function map_in_mode(mode, key, cmd, opts)
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
    set_keymap = function (_mode, _key, _cmd, _options)
      vim.api.nvim_buf_set_keymap(buf, _mode, _key, _cmd, _options)
    end
  else
    set_keymap = vim.api.nvim_set_keymap
  end

  -- create a mapping for every mode in the mode string
  if mode == '' then
    set_keymap(mode, key, cmd, options)
  else
    mode:gsub('.', function (m)
      set_keymap(m, key, cmd, options)
    end)
  end
end

-- map a key in all modes
function util.keys.map(key, cmd, opts)
	map_in_mode('', key, cmd, opts)
end

-- map a key in normal mode using the leader key
function util.keys.lmap(key, cmd, opts)
	map_in_mode('n', '<leader>' .. key, cmd, opts)
end

-- map a key in insert mode using the leader key
function util.keys.imap(key, cmd, opts)
	map_in_mode('i', key, cmd, opts)
end

-- map a key in insert mode using the leader key
function util.keys.nmap(key, cmd, opts)
	map_in_mode('n', key, cmd, opts)
end

-- create an augroup from a name and list of commands
-- commands are of the form
--   { group, definition }
function util.augroup(name, commands)
	vim.cmd('augroup ' .. name)
	vim.cmd('autocmd!')
	for _, def in ipairs(commands) do
		vim.cmd('autocmd ' .. def)
	end
	vim.cmd('augroup END')
end

-- create a vim command
function util.cmd(name, argsOrCmd, cmd)
	local args = cmd and argsOrCmd or nil
	cmd = cmd and cmd or argsOrCmd

	if args == nil then
		vim.cmd('command! ' .. name .. ' ' .. cmd)
	else
		vim.cmd('command! ' .. args .. ' ' .. name .. ' ' .. cmd)
	end
end

-- restore cursor position
function util.restore_cursor()
	if vim.bo.filetype == 'gitcommit' or vim.bo.buftype == 'nofile' then
		return
	end
	vim.cmd('g`"')
end

-- settings for text files
function util.text_mode()
	vim.wo.wrap = true
	vim.wo.linebreak = true
	vim.wo.list = false
	vim.wo.signcolumn = 'no'
end

-- set colorcolumn to show the current textwidth
function util.show_view_width()
	local tw = vim.bo.textwidth
	if tw and tw > 0 then
		vim.wo.colorcolumn = vim.fn.join(vim.fn.range(tw + 1, tw + 1 + 256), ',')
	end
end

-- set window height
function util.adjust_window_height(minheight, maxheight)
  local line = vim.fn.line('$')
  local val = vim.fn.max({ vim.fn.min({ line, maxheight }), minheight })
	vim.cmd(val .. 'wincmd _')
end

-- trim characters from a string
function util.trim(str, char)
  if char == nil then
    char = '%s'
  end
  return str:gsub('^' .. char .. '+', ''):gsub(char .. '+$', '')
end

-- define a syntax highlight group
function util.hi(group, props)
  local props_list = {}
  for k, v in pairs(props) do
    -- replace an empty value with NONE
    local val = v == '' and 'NONE' or v

    -- if gui{fg,bg,sp} don't start with a '#', prepend it
    if k:find('gui%a') and v:sub(1, 1) ~= '#' then
      val = '#' .. val
    end

    table.insert(props_list, k .. '=' .. val)
  end
  vim.cmd('hi ' .. group .. ' ' .. table.concat(props_list, ' '))
end

return util
