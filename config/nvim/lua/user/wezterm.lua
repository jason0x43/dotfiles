local M = {}

---@param dir 'k' | 'j' | 'h' | 'l'
---@return number | string
M.go_dir = function(dir)
  local curr_win = vim.fn.winnr()
  vim.api.nvim_command("wincmd " .. dir)
  if curr_win == vim.fn.winnr() then
    return ''
  end
  return vim.fn.winnr()
end

M.go_up = function()
  return M.go_dir('k')
end

M.go_down = function()
  return M.go_dir('j')
end

M.go_left = function()
  return M.go_dir('h')
end

M.go_right = function()
  return M.go_dir('l')
end

return M
