-- This file is used by terminal clients to control the currently focused window
-- in neovim. It's a function rather than an ex command because neovim's
-- remote-expr functionality needs to call a function to get a useful return
-- value.

local directions = { up = 'k', down = 'j', left = 'h', right = 'l' }

local M = {}

---Focus the pane in a given direction
---@param dir 'up' | 'down' | 'left' | 'right'
---@return number | string
M.focus = function(dir)
  local curr_win = vim.fn.winnr()
  vim.api.nvim_command('wincmd ' .. directions[dir])
  if curr_win == vim.fn.winnr() then
    return ''
  end
  return vim.fn.winnr()
end

M.focus_kitty = function(dir)
  local curr_win = vim.fn.winnr()
  vim.api.nvim_command('wincmd ' .. directions[dir])
  if curr_win == vim.fn.winnr() then
    vim.fn.system('kitty @ kitten nvim_nav.py nvim ' .. dir)
  end
end

M.colorize = function()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.statuscolumn = ''
  vim.wo.signcolumn = 'no'
  vim.opt.listchars = { space = ' ' }

  local buf = vim.api.nvim_get_current_buf()

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  while #lines > 0 and vim.trim(lines[#lines]) == '' do
    lines[#lines] = nil
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  vim.api.nvim_chan_send(
    vim.api.nvim_open_term(buf, {}),
    table.concat(lines, '\r\n')
  )

  vim.keymap.set('n', 'q', '<cmd>qa!<cr>', { silent = true, buffer = buf })

  vim.api.nvim_create_autocmd(
    'TextChanged',
    { buffer = buf, command = 'normal! G$' }
  )

  vim.api.nvim_create_autocmd(
    'TermEnter',
    { buffer = buf, command = 'stopinsert' }
  )
end

return M
