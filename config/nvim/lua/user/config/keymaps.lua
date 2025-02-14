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

vim.keymap.set('n', '<leader>a', function()
  vim.lsp.buf.code_action()
end, { desc = 'Show a list of possible code actions' })

vim.keymap.set('n', '<leader>b', function()
  require('snacks').picker.buffers()
end, { desc = 'Open a buffer picker' })

vim.keymap.set('n', '<leader>c', function()
  local wins = vim.api.nvim_list_wins()
  if #wins == 1 then
    -- If only one window is open, delete the contained buffer to accomplish the
    -- same goal as closing
    Snacks.bufdelete.delete()
  else
    vim.api.nvim_win_close(0, false)
  end
end, { desc = 'Close the current pane' })

vim.keymap.set('n', '<leader>d', function()
  require('snacks').picker.diagnostics()
end, { desc = 'Show all diagnostics' })

vim.keymap.set('n', '<leader>D', function()
  vim.diagnostic.open_float({
    border = 'rounded',
  })
end, { desc = 'Show diagnostics for the current line' })

vim.keymap.set('n', '<leader>f', function()
  require('snacks').picker.files()
end, { desc = 'Open a file picker' })

vim.keymap.set('n', '<leader>F', function()
  require('conform').format({ lsp_fallback = true })
end, { desc = 'Format the current file' })

vim.keymap.set('n', '<leader>g', function()
  Snacks.picker.grep()
end, { desc = 'Search for strings in files' })

vim.keymap.set('n', '<leader>h', function()
  Snacks.picker.help()
end, { desc = 'Open a help page picker' })

vim.keymap.set('n', '<leader>k', function()
  Snacks.bufdelete.delete()
end, { desc = 'Close the current buffer' })

vim.keymap.set('n', '<leader>K', function()
  Snacks.bufdelete.delete({ force = true })
end, { desc = 'Close the current buffer with prejudice' })

vim.keymap.set('n', '<leader>ls', function()
  Snacks.picker.lsp_symbols()
end, { desc = 'List symbols in the current project' })

vim.keymap.set('n', '<leader>lr', function()
  Snacks.picker.lsp_references()
end, { desc = 'List references to the symbol under the cursor' })

vim.keymap.set('n', '<leader>m', function()
  Snacks.picker.git_status()
end, { desc = 'Open a modified-files picker' })

vim.keymap.set('n', '<leader>n', function()
  Snacks.picker.explorer({
    cwd = vim.fn.expand('%:p:h'),
  })
end, { desc = 'Open a file explorer' })

-- Quit vim
vim.keymap.set('n', '<leader>q', '<cmd>qall<cr>', { desc = 'Exit vim' })
vim.keymap.set(
  'n',
  '<leader>Q',
  '<cmd>qall!<cr>',
  { desc = 'Exit vim with prejudice' }
)

vim.keymap.set('n', '<leader>r', function()
  vim.lsp.buf.rename()
end, { desc = 'Rename the symbol under the cursor' })

vim.keymap.set('n', '<leader>s', function()
  ---@diagnostic disable-next-line: undefined-field
  Snacks.picker.smart()
end, { desc = "Open the 'smart' picker" })

vim.keymap.set('n', '<leader>t', function()
  Snacks.terminal.open()
end, { desc = 'Open a terminal' })

vim.keymap.set('n', '<leader>u', function()
  ---@diagnostic disable-next-line: undefined-field
  Snacks.picker.undo()
end, { desc = 'Open undo history' })

vim.keymap.set('n', '<leader>z', function()
  Snacks.picker.zoxide()
end, { desc = 'Open the zoxide picker' })

-- Save the current file
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', {
  desc = 'Save the current file',
})
vim.keymap.set('n', '<leader>W', '<cmd>w!<cr>', {
  desc = 'Save all open files',
})
