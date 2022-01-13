-- Handle navigating between various splits (vim, kitty, tmux)

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
