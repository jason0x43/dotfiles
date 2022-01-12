-- Like Navigator, but for kitty.
-- Handle navigating between vim windows and kitty windows.

-- only load this if we're not using tmux
if vim.fn.getenv('TMUX') ~= vim.NIL then
  return
end

local util = require('user.util')
util.nmap('<c-h>', '<cmd>lua require("user.kitty").kittyNav("h")<cr>')
util.nmap('<c-j>', '<cmd>lua require("user.kitty").kittyNav("j")<cr>')
util.nmap('<c-k>', '<cmd>lua require("user.kitty").kittyNav("k")<cr>')
util.nmap('<c-l>', '<cmd>lua require("user.kitty").kittyNav("l")<cr>')

local mappings = {
  h = "left",
  j = "bottom",
  k = "top",
  l = "right"
}

local M = {}

function M.kittyNav(direction)
  local initial_win = vim.fn.winnr()

  vim.cmd('wincmd ' .. direction)

  if vim.fn.winnr() == initial_win then
    vim.fn.system('kitty @ kitten nvim_nav.py nvim ' .. mappings[direction])
  end
end

return M
