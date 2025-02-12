---Create a normal mode key mapping
---@param key string
---@param callback function | string
local function key_map(key, callback)
  vim.keymap.set('n', key, callback, {})
end

-- Toggle crosshairs
key_map('#', function()
  if vim.wo.cursorline and vim.wo.cursorcolumn then
    vim.wo.cursorline = false
    vim.wo.cursorcolumn = false
  elseif vim.wo.cursorline then
    vim.wo.cursorcolumn = true
  else
    vim.wo.cursorline = true
  end
end)

-- Space to clear search highlights
key_map('<space>', function()
  vim.go.hlsearch = false
end)

-- Disable "Entering Ex mode"
key_map('Q', '<nop>')

-- Go to previous buffer
vim.keymap.set('n', '<leader><leader>', '<C-^>')

vim.keymap.set('n', '<leader>a', function()
  vim.lsp.buf.code_action()
end)

vim.keymap.set('n', '<leader>b', function()
  require('snacks').picker.buffers()
end)

-- Close a window
vim.keymap.set('n', '<leader>c', function()
  vim.api.nvim_win_close(0, false)
end)

vim.keymap.set('n', '<leader>e', function()
  require('snacks').picker.diagnostics()
end)

vim.keymap.set('n', '<leader>d', function()
  vim.diagnostic.open_float({
    border = 'rounded',
  })
end)

vim.keymap.set('n', '<leader>f', function()
  require('snacks').picker.files()
end)

vim.keymap.set('n', '<leader>F', function()
  require('conform').format({ lsp_fallback = true })
end)

vim.keymap.set('n', '<leader>g', function()
  Snacks.picker.grep()
end)

vim.keymap.set('n', '<leader>h', function()
  Snacks.picker.help()
end)

vim.keymap.set('n', '<leader>k', function()
  Snacks.bufdelete.delete()
end)

vim.keymap.set('n', '<leader>K', function()
  Snacks.bufdelete.delete({ force = true })
end)

vim.keymap.set('n', '<leader>ls', function()
  Snacks.picker.lsp_symbols()
end)

vim.keymap.set('n', '<leader>lr', function()
  Snacks.picker.lsp_references()
end)

vim.keymap.set('n', '<leader>m', function()
  Snacks.picker.git_status()
end)

vim.keymap.set('n', '<leader>n', function()
  Snacks.picker.explorer({
    cwd = vim.fn.expand('%:p:h'),
  })
end)

-- Quit vim
vim.keymap.set('n', '<leader>q', '<cmd>qall<cr>')
vim.keymap.set('n', '<leader>Q', '<cmd>qall!<cr>')

vim.keymap.set('n', '<leader>r', function()
  vim.lsp.buf.rename()
end)

vim.keymap.set('n', '<leader>s', function()
  ---@diagnostic disable-next-line: undefined-field
  Snacks.picker.smart()
end)

vim.keymap.set('n', '<leader>t', function()
  Snacks.terminal.open()
end)

vim.keymap.set('n', '<leader>u', function()
  ---@diagnostic disable-next-line: undefined-field
  Snacks.picker.undo()
end)

vim.keymap.set('n', '<leader>z', function()
  Snacks.picker.zoxide()
end)

-- Save the current file
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>')
vim.keymap.set('n', '<leader>W', '<cmd>w!<cr>')
