local keys = require('util').keys

vim.g.mapleader = ';'

-- go to previous buffer
keys.lmap('<leader>', '<C-^>')

-- toggle crosshairs
keys.map('#', ':set cursorcolumn! cursorline!<cr>')

-- save the current file
keys.lmap('w', ':w<cr>')
keys.lmap('W', ':w!<cr>')

-- quit vim
keys.lmap('q', ':qall<cr>')
keys.lmap('Q', ':qall!<cr>')

-- close a window
keys.lmap('c', ':close<cr>')

-- show the syntax highlight state of the character under the cursor
keys.lmap(
  'h',
  ':echo "hi<synIDattr(synID(line("."),col("."),1),"name") . '
    .. '"> trans<" . synIDattr(synID(line("."),col("."),0),"name") . '
    .. '"> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . '
    .. '">"<cr>'
)

-- use tab for completions
keys.imap('<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true })
keys.imap('<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', { expr = true })

-- space to clear search highlights
keys.map('<space>', ':noh<cr>')

-- yank to and paste from system clipboard
keys.lmap(
  'y',
  'y:<C-U>lua require("util").yank(vim.fn.getreg("0"))<CR>',
  { mode = 'nvo' }
)
keys.lmap('p', '"*p')
