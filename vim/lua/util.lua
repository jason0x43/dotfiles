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
	local escape = vim.fn.system('term_copy', text)
	if vim.v.shell_error == 1 then
		vim.cmd('echoerr ' .. escape)
	else
		vim.fn.writefile({ escape }, '/dev/tty', 'b')
	end
end

util.keys = {}

-- map a key in a particular mode
-- for a buffer-specific map pass a `buffer` option
local function map_in_mode(mode, key, cmd, opts)
	local options = { noremap = true, silent = true }
  local buf

  -- <plug> mappings won't work with noremap
  local cmd_lower = cmd:lower()
  if cmd_lower:find('<plug>') then
    options.noremap = nil
  end

  if opts and opts.buffer then
    buf = opts.buffer == true and 0 or opts.buffer
  end

	if opts then
		options = vim.tbl_extend('force', options, opts)
	end

  if buf then
    options.buffer = nil
    vim.api.nvim_buf_set_keymap(buf, mode, key, cmd, options)
  else
    vim.api.nvim_set_keymap(mode, key, cmd, options)
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
	local tw = vim.b.textwidth
	if tw and tw > 0 then
		vim.b.colorcolumn = vim.fn.join(vim.fn.range(tw + 1, tw + 1 + 256), ',')
	end
end

-- set window height
function util.adjust_window_height(minheight, maxheight)
	vim.cmd('max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"')
end

-- trim characters from a string
function util.trim(str, char)
  if char == nil then
    char = '%s'
  end
  return str:gsub('^' .. char .. '+', ''):gsub(char .. '+$', '')
end

-- Define a syntax highlight group
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
