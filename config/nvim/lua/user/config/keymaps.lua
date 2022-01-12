local util = require('user.util')

vim.g.mapleader = ';'

-- go to previous buffer
util.lmap('<leader>', '<C-^>')

-- toggle crosshairs
util.map('#', '<cmd>set cursorcolumn! cursorline!<cr>')

-- save the current file
util.lmap('w', '<cmd>w<cr>')
util.lmap('W', '<cmd>w!<cr>')

-- quit vim
util.lmap('q', '<cmd>qall<cr>')
util.lmap('Q', '<cmd>qall!<cr>')

-- close a window
util.lmap('c', '<cmd>close<cr>')

-- show the syntax highlight state of the character under the cursor
util.lmap(
  'hl',
  '<cmd>lua require("user.util").print_syn_group()<cr>'
)

-- space to clear search highlights
util.map('<space>', '<cmd>noh<cr>')

-- yank to and paste from system clipboard
util.lmap(
  'y',
  'y<cmd>lua require("user.util").yank(vim.fn.getreg("0"))<CR>',
  { mode = 'nvo' }
)
util.lmap('p', '"*p')

-- disable "Entering Ex mode"
util.map('Q', '<nop>')
