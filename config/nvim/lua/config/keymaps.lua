local keys = require('util').keys

vim.g.mapleader = ';'

-- go to previous buffer
keys.lmap('<leader>', '<C-^>')

-- toggle crosshairs
keys.map('#', '<cmd>set cursorcolumn! cursorline!<cr>')

-- save the current file
keys.lmap('w', '<cmd>w<cr>')
keys.lmap('W', '<cmd>w!<cr>')

-- kill a buffer without closing its window
keys.lmap('k', ':Bdelete<cr>')
keys.lmap('K', ':Bdelete!<cr>')

-- quit vim
keys.lmap('q', '<cmd>qall<cr>')
keys.lmap('Q', '<cmd>qall!<cr>')

-- close a window
keys.lmap('c', '<cmd>close<cr>')

-- show the syntax highlight state of the character under the cursor
keys.lmap(
  'h',
  '<cmd>echo "hi<synIDattr(synID(line("."),col("."),1),"name") . '
    .. '"> trans<" . synIDattr(synID(line("."),col("."),0),"name") . '
    .. '"> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . '
    .. '">"<cr>'
)

-- use tab for completions
keys.imap('<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true })
keys.imap('<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', { expr = true })

-- space to clear search highlights
keys.map('<space>', '<cmd>noh<cr>')

-- yank to and paste from system clipboard
keys.lmap(
  'y',
  'y:<C-U>lua require("util").yank(vim.fn.getreg("0"))<CR>',
  { mode = 'nvo' }
)
keys.lmap('p', '"*p')

-- telescope
keys.lmap('f', '<cmd>Telescope find_files<cr>')
keys.lmap('g', '<cmd>Telescope git_files<cr>')
keys.lmap('b', '<cmd>Telescope buffers<cr>')
keys.lmap('tg', '<cmd>Telescope live_grep<cr>')
keys.lmap('th', '<cmd>Telescope help_tags<cr>')
keys.lmap('tl', '<cmd>Telescope highlights<cr>')
keys.lmap('to', '<cmd>Telescope oldfiles<cr>')
keys.lmap('tr', '<cmd>Telescope frecency<cr>')
keys.lmap('ts', '<cmd>Telescope symbols<cr>')
keys.lmap('lr', '<cmd>Telescope lsp_references<cr>')
keys.lmap('ls', '<cmd>Telescope lsp_document_symbols<cr>')
keys.lmap('la', '<cmd>Telescope lsp_code_actions<cr>')
keys.lmap('ld', '<cmd>Telescope lsp_workspace_diagnostics()<cr>')
keys.imap('<C-e>', '<cmd>Telescope symbols<cr>')

-- open startify
keys.lmap('s', '<cmd>Startify<cr>')

-- open NvimTree
keys.lmap('n', '<cmd>NvimTreeToggle<cr>')

-- open UndoTree
keys.lmap('u', '<cmd>UndotreeToggle<cr>')
