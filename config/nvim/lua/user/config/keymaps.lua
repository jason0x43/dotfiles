-- Toggle line and column highlighting
vim.keymap.set('n', '#', function()
  if vim.wo.cursorline and vim.wo.cursorcolumn then
    vim.wo.cursorline = false
    vim.wo.cursorcolumn = false
  elseif vim.wo.cursorline then
    vim.wo.cursorcolumn = true
  else
    vim.wo.cursorline = true
  end
end, { desc = 'Toggle line and column highlighting' })

-- Space to clear search highlights
vim.keymap.set('n', '<space>', function()
  vim.go.hlsearch = false
end, { desc = 'Go the previous buffer' })

-- Disable "Entering Ex mode"
vim.keymap.set('n', 'Q', '<nop>', { desc = 'Disable entering Ex mode' })

-- Go to the previous buffer
vim.keymap.set(
  'n',
  '<leader><leader>',
  '<C-^>',
  { desc = 'Go to the previous buffer' }
)

-- Show code actions
vim.keymap.set('n', '<leader>a', function()
  vim.lsp.buf.code_action()
end, { desc = 'Show a list of possible code actions' })

-- Show diagnostics
vim.keymap.set('n', '<leader>D', function()
  vim.diagnostic.open_float({
    border = 'rounded',
  })
end, { desc = 'Show diagnostics for the current line' })

-- Insert a UUID
vim.keymap.set('n', '<leader>iu', function()
  local uuid = vim.fn.system('uuidgen')
  uuid = require('user.util.string').trim(uuid)
  uuid = vim.fn.tolower(uuid)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
end, { desc = 'Insert a UUID at the cursor position' })

-- Insert a capitalized UUID
vim.keymap.set('n', '<leader>iU', function()
  local uuid = vim.fn.system('uuidgen')
  uuid = require('user.util.string').trim(uuid)
  uuid = vim.fn.toupper(uuid)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
end, { desc = 'Insert an all-caps UUID at the cursor position' })

-- Quit vim
vim.keymap.set('n', '<leader>q', '<cmd>qall<cr>', { desc = 'Exit vim' })
vim.keymap.set(
  'n',
  '<leader>Q',
  '<cmd>qall!<cr>',
  { desc = 'Exit vim with prejudice' }
)

-- Save the current file
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', {
  desc = 'Save the current file',
})
vim.keymap.set('n', '<leader>W', '<cmd>w!<cr>', {
  desc = 'Save all open files',
})

-- Window movement keys for Windows
if vim.fn.has('win32') then
  vim.keymap.set(
    { 'n', 'i' },
    '<c-h>',
    '<cmd>wincmd h<cr>',
    { desc = 'Focus the window to the left' }
  )
  vim.keymap.set(
    { 'n', 'i' },
    '<c-j>',
    '<cmd>wincmd j<cr>',
    { desc = 'Focus the window below' }
  )
  vim.keymap.set(
    { 'n', 'i' },
    '<c-k>',
    '<cmd>wincmd k<cr>',
    { desc = 'Focus the window above' }
  )
  vim.keymap.set(
    { 'n', 'i' },
    '<c-l>',
    '<cmd>wincmd l<cr>',
    { desc = 'Focus the window to the right' }
  )
end
