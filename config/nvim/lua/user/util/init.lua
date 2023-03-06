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

-- settings for text files
function M.text_mode()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.list = false
  vim.wo.signcolumn = 'no'

	vim.keymap.set('', 'k', 'gk', { buffer = 0 })
  vim.keymap.set('', 'j', 'gj', { buffer = 0 })
  vim.keymap.set('', '$', 'g$', { buffer = 0 })
  vim.keymap.set('', '^', 'g^', { buffer = 0 })
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
