---Create a normal mode key mapping
---@param key string
---@param callback function | string
local function key_map(key, callback)
  vim.keymap.set('n', key, callback, {})
end

---Create a leader mapping
---@param key string
---@param callback function | string
local function leader_map(key, callback)
  vim.keymap.set('n', '<leader>' .. key, callback, {})
end

-- toggle crosshairs
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

-- space to clear search highlights
key_map('<space>', function()
  vim.go.hlsearch = false
end)

-- disable "Entering Ex mode"
key_map('Q', '<nop>')

-- go to previous buffer
leader_map('<leader>', '<C-^>')

leader_map('a', function()
  vim.lsp.buf.code_action()
end)

leader_map('b', function()
  require('snacks').picker.buffers()
end)

-- close a window
leader_map('c', function()
  vim.api.nvim_win_close(0, false)
end)

leader_map('d', function()
  require('snacks').picker.diagnostics()
end)

leader_map('f', function()
  require('snacks').picker.files()
end)

leader_map('F', function()
  require('conform').format({ lsp_fallback = true })
end)

leader_map('g', function()
  Snacks.picker.grep()
end)

leader_map('h', function()
  Snacks.picker.help()
end)

leader_map('k', function()
  Snacks.bufdelete.delete()
end)

leader_map('K', function()
  Snacks.bufdelete.delete({ force = true })
end)

leader_map('ls', function()
  Snacks.picker.lsp_symbols()
end)

leader_map('lr', function()
  Snacks.picker.lsp_references()
end)

leader_map('m', function()
  Snacks.picker.git_status()
end)

leader_map('n', function()
  Snacks.picker.explorer()
end)

-- quit vim
leader_map('q', '<cmd>qall<cr>')
leader_map('Q', '<cmd>qall!<cr>')

leader_map('r', function()
  vim.lsp.buf.rename()
end)

leader_map('s', function()
  ---@diagnostic disable-next-line: undefined-field
  Snacks.picker.smart()
end)

leader_map('t', function()
  Snacks.terminal.open()
end)

leader_map('u', function()
  ---@diagnostic disable-next-line: undefined-field
  Snacks.picker.undo()
end)

-- save the current file
leader_map('w', '<cmd>w<cr>')
leader_map('W', '<cmd>w!<cr>')
