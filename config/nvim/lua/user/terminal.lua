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

return M
