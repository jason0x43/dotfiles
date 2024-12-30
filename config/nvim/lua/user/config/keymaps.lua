-- go to previous buffer
vim.keymap.set('n', '<leader><leader>', '<C-^>')

-- toggle crosshairs
vim.keymap.set('n', '#', function()
  if vim.wo.cursorline and vim.wo.cursorcolumn then
    vim.wo.cursorline = false
    vim.wo.cursorcolumn = false
  elseif vim.wo.cursorline then
    vim.wo.cursorcolumn = true
  else
    vim.wo.cursorline = true
  end
end)

-- save the current file
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>')
vim.keymap.set('n', '<leader>W', '<cmd>w!<cr>')

-- quit vim
vim.keymap.set('n', '<leader>q', '<cmd>qall<cr>')
vim.keymap.set('n', '<leader>Q', '<cmd>qall!<cr>')

-- close a window
vim.keymap.set('n', '<leader>c', function()
  vim.api.nvim_win_close(0, false)
end)

-- space to clear search highlights
vim.keymap.set('', '<space>', function()
  vim.go.hlsearch = false
end)

-- yank to and paste from system clipboard
vim.keymap.set({ 'n', 'v', 'o' }, '<leader>y', function()
  require('user.util').yank(vim.fn.getreg('0'))
end)
vim.keymap.set('n', '<leader>p', '"*p')

-- disable "Entering Ex mode"
vim.keymap.set('', 'Q', '<nop>')
