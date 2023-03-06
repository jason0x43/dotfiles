-- Handle navigating between various splits (vim, kitty, tmux)

vim.keymap.set('n', '<c-h>', '<cmd>lua require("user.kitty").kittyNav("h")<cr>')
vim.keymap.set('n', '<c-j>', '<cmd>lua require("user.kitty").kittyNav("j")<cr>')
vim.keymap.set('n', '<c-k>', '<cmd>lua require("user.kitty").kittyNav("k")<cr>')
vim.keymap.set('n', '<c-l>', '<cmd>lua require("user.kitty").kittyNav("l")<cr>')

local dirs = {
  h = "left",
  j = "bottom",
  k = "top",
  l = "right"
}

local tmux_dirs = {
  h = "L",
  j = "D",
  k = "U",
  l = "R"
}

local M = {}

function M.kittyNav(direction)
  local initial_win = vim.fn.winnr()
  vim.cmd('wincmd ' .. direction)
  if vim.fn.winnr() == initial_win then
    if os.getenv('TMUX') then
      vim.fn.system('tmux select-pane -' .. tmux_dirs[direction])
    else
      vim.fn.system('kitty @ kitten nvim_nav.py nvim ' .. dirs[direction])
    end
  end
end

return M
