local M = {}

-- yank to terminal
-- https://sunaku.github.io/tmux-yank-osc52.html
---@param text string
---@return nil
M.yank = function(text)
  local escape = vim.fn.system('term_copy', text)
  if vim.v.shell_error == 1 then
    vim.cmd('echoerr ' .. escape)
  else
    vim.fn.writefile({ escape }, '/dev/tty', 'b')
  end
end

-- settings for text files
---@return nil
M.text_mode = function()
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
---@return nil
M.show_view_width = function()
  local filetype = vim.bo.filetype
  local tw = vim.bo.textwidth

  if vim.wo.diff or filetype == 'help' or tw == 0 then
    vim.wo.colorcolumn = ''
  else
    vim.wo.colorcolumn =
      vim.fn.join(vim.fn.range(tw + 1, tw + 1 + vim.go.columns), ',')
  end
end

-- set window height within a min/max range
---@param minheight number
---@param maxheight number
---@return nil
M.adjust_window_height = function(minheight, maxheight)
  local line = vim.fn.line('$')
  local val = vim.fn.max({ vim.fn.min({ line, maxheight }), minheight })
  vim.cmd(val .. 'wincmd _')
end

-- restore the cursor position in a file
---@return nil
M.restore_cursor = function()
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
end

-- print the syntax highlight information at the current location
---@return nil
M.print_syn_group = function()
  local buf = vim.api.nvim_get_current_buf()
  local ts_hl = require('vim.treesitter.highlighter')
  if ts_hl.active[buf] then
    vim.cmd('TSCaptureUnderCursor')
  else
    local ls = vim.fn.synID(vim.fn.line('.'), vim.fn.col('.'), 1)
    if ls ~= 0 then
      print(
        vim.fn.synIDattr(ls, 'name')
          .. ' -> '
          .. vim.fn.synIDattr(vim.fn.synIDtrans(ls), 'name')
      )
    else
      print('No highlight')
    end
  end
end

-- return true if the cwd is in a git work tree
---@return boolean
M.in_git_dir = function()
  vim.fn.system({ 'git', 'rev-parse', '--is-inside-work-tree' })
  return vim.v.shell_error == 0
end

-- return true of the string str starts with the string other
---@param str string
---@param other string
---@return boolean
M.starts_with = function(str, other)
  return str:sub(1, #other) == other
end

---Create a global user command
---@param name string
---@param callback function
---@param opts vim.api.keyset.user_command | nil
M.user_cmd = function(name, callback, opts)
  vim.api.nvim_create_user_command(name, callback, opts or {})
end

---Create a buffer-local user command
---@param name string
---@param callback function
---@param opts vim.api.keyset.user_command | nil
M.user_buf_cmd = function(name, callback, opts)
  vim.api.nvim_buf_create_user_command(0, name, callback, opts or {})
end

---Create a leader mapping
---@param key string
---@param callback function | string
M.leader_map = function(key, callback)
  vim.keymap.set('n', '<leader>' .. key, callback, {})
end

return M
