local util = require('util')

vim.g.mapleader = ';'

-- go to previous buffer
util.lmap('<leader>', '<C-^>')

-- toggle crosshairs
util.map('#', '<cmd>set cursorcolumn! cursorline!<cr>')

-- save the current file
util.lmap('w', '<cmd>w<cr>')
util.lmap('W', '<cmd>w!<cr>')

-- kill a buffer without closing its window
util.lmap('k', ':Bdelete<cr>')
util.lmap('K', ':Bdelete!<cr>')

-- quit vim
util.lmap('q', '<cmd>qall<cr>')
util.lmap('Q', '<cmd>qall!<cr>')

-- close a window
util.lmap('c', '<cmd>close<cr>')

-- show the syntax highlight state of the character under the cursor
util.lmap(
  'hl',
  '<cmd>lua require("util").print_syn_group()<cr>'
)

-- use tab for completions
util.imap('<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true })
util.imap('<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', { expr = true })

-- space to clear search highlights
util.map('<space>', '<cmd>noh<cr>')

-- yank to and paste from system clipboard
util.lmap(
  'y',
  'y:<C-U>lua require("util").yank(vim.fn.getreg("0"))<CR>',
  { mode = 'nvo' }
)
util.lmap('p', '"*p')

-- telescope
util.lmap('f', '<cmd>Telescope find_files<cr>')
util.lmap('g', '<cmd>Telescope git_files<cr>')
util.lmap('b', '<cmd>Telescope buffers<cr>')
util.lmap('tg', '<cmd>Telescope live_grep<cr>')
util.lmap('th', '<cmd>Telescope help_tags<cr>')
util.lmap('tl', '<cmd>Telescope highlights<cr>')
util.lmap('to', '<cmd>Telescope oldfiles<cr>')
util.lmap('tr', '<cmd>Telescope frecency<cr>')
util.lmap('ts', '<cmd>Telescope symbols<cr>')
util.lmap('lr', '<cmd>Telescope lsp_references<cr>')
util.lmap('ls', '<cmd>Telescope lsp_document_symbols<cr>')
util.lmap('la', '<cmd>Telescope lsp_code_actions<cr>')
util.lmap('ld', '<cmd>Telescope lsp_workspace_diagnostics<cr>')
util.imap('<C-e>', '<cmd>Telescope symbols<cr>')

-- open startify
util.lmap('s', '<cmd>Startify<cr>')

-- open NvimTree
util.lmap('n', '<cmd>NvimTreeToggle<cr>')

-- open UndoTree
util.lmap('u', '<cmd>UndotreeToggle<cr>')
