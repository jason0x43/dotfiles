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

vim.keymap.set('n', '<leader>_', function()
  require('dropbar.api').pick()
end, { desc = 'Pick symbols in winbar' })

vim.keymap.set('n', '[_', function()
  require('dropbar.api').goto_context_start()
end, { desc = 'Go to start of current context' })

vim.keymap.set('n', ']_', function()
  require('dropbar.api').select_next_context()
end, { desc = 'Select next context' })

vim.keymap.set('n', '<leader>a', function()
  vim.lsp.buf.code_action()
end, { desc = 'Show a list of possible code actions' })

vim.keymap.set('n', '<leader>b', function()
  require('mini.pick').builtin.buffers()
end, { desc = 'Find buffers' })

-- Close the current window
vim.keymap.set('n', '<leader>c', function()
  ---@type boolean, string | nil
  local ok, err = pcall(function()
    vim.cmd('close')
  end)
  if not ok and err and string.match(err, 'E444') then
    vim.cmd('quit')
  end
end, { desc = 'Close the current window' })

vim.keymap.set('n', '<leader>d', function()
  require('mini.pick').registry.diagnostic({ scope = 'current' })
end, { desc = 'List diagnostics' })

-- Show diagnostics
vim.keymap.set('n', '<leader>D', function()
  vim.diagnostic.open_float({
    border = 'rounded',
  })
end, { desc = 'Show diagnostics for the current line' })

vim.keymap.set('n', '<leader>e', function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.getcwd()
  if vim.uv.fs_stat(bufname) then
    dir = vim.fn.fnamemodify(bufname, ':p:h')
  end
  require('mini.files').open(dir)
end, { desc = 'Open a file manager' })

vim.keymap.set('n', '<leader>f', function()
  require('mini.pick').registry.smart()
end, { desc = 'Find files' })

vim.keymap.set('n', '<leader>F', function()
  require('conform').format({ lsp_fallback = true, async = true })
end, { desc = 'Format the current file' })

vim.keymap.set('n', '<leader>g', function()
  require('mini.pick').builtin.grep_live()
end, { desc = 'Find strings in files' })

vim.keymap.set('n', '<leader>h', function()
  require('mini.pick').builtin.help()
end, { desc = 'Find help' })

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

vim.keymap.set('n', '<leader>k', function()
  require('mini.bufremove').delete()
end, { desc = 'Close the current buffer' })

vim.keymap.set('n', '<leader>K', function()
  require('mini.bufremove').delete(0, true)
end, { desc = 'Close the current buffer with prejudice' })

vim.keymap.set('n', '<leader>li', function()
  vim.lsp.buf.implementation()
end, { desc = 'Go to the implementation of a symbol' })

vim.keymap.set('n', '<leader>ll', function()
  require('user.util.lsp').get_document_location()
end, { desc = 'Find help' })

vim.keymap.set('n', '<leader>lr', function()
  require('mini.extra').pickers.lsp({ scope = 'references' })
end, { desc = 'Find help' })

vim.keymap.set('n', '<leader>ls', function()
  require('mini.extra').pickers.lsp({ scope = 'document_symbol' })
end, { desc = 'Find help' })

vim.keymap.set('n', '<leader>lS', function()
  local query = vim.fn.input('Symbol query: ')
  require('mini.extra').pickers.lsp({
    scope = 'workspace_symbol',
    symbol_query = query,
  })
end, { desc = 'Find help' })

vim.keymap.set('n', '<leader>r', function()
  require('mini.pick').registry.recent({ current_dir = true })
end, { desc = 'Find recent files' })

vim.keymap.set('n', '<leader>s', function()
  require('mini.starter').open()
end, { desc = 'Open the mini starter screen' })

vim.keymap.set('n', '<leader>u', function()
  require('mini.pick').registry.undotree()
end, { desc = 'List diagnostics' })

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

vim.keymap.set({ 'n', 'i' }, '<c-h>', function()
  require('user.terminal').focus_kitty('left')
end, { desc = 'Focus the window to the left' })
vim.keymap.set({ 'n', 'i' }, '<c-j>', function()
  require('user.terminal').focus_kitty('down')
end, { desc = 'Focus the window below' })
vim.keymap.set({ 'n', 'i' }, '<c-k>', function()
  require('user.terminal').focus_kitty('up')
end, { desc = 'Focus the window above' })
vim.keymap.set({ 'n', 'i' }, '<c-l>', function()
  require('user.terminal').focus_kitty('right')
end, { desc = 'Focus the window to the right' })

vim.keymap.set('n', '<leader>y', function()
  require('user.config.yazi').open_yazi()
end)

vim.keymap.set(
  'n',
  '<leader>z',
  '<cmd>CodeCompanionChat Toggle<cr>',
  { desc = 'Open a CodeCompanion chat window' }
)

vim.keymap.set(
  'n',
  '<leader>Z',
  '<cmd>CodeCompanionActions<cr>',
  { desc = 'Open CodeCompanion actions panel' }
)

-- Override the default "goto definition" handler to use relative paths
-- vim.keymap.set('n', '<c-]>', function()
--   local params = vim.lsp.util.make_position_params(0, 'utf-16')
--
--   vim.lsp.buf_request(
--     0,
--     'textDocument/definition',
--     params,
--     function(err, result, _, _)
--       if
--         err
--         or not result
--         or (type(result) == 'table' and vim.tbl_isempty(result))
--       then
--         print('No results')
--         return
--       end
--
--       -- pick first location
--       local loc = vim.islist(result) and result[1] or result
--       local uri = loc.targetUri or loc.uri
--       local abs = vim.uri_to_fname(uri)
--       local rel = vim.fn.fnamemodify(abs, ':.')
--
--       -- open the file if it's different than the current file
--       local curr_file = vim.api.nvim_buf_get_name(0)
--       local rel_curr_file = vim.fn.fnamemodify(curr_file, ':.')
--       if rel ~= rel_curr_file then
--         vim.cmd(":e " .. rel)
--       end
--
--       -- place the cursor to the target location
--       local range = loc.targetSelectionRange or loc.range
--       local start = range.start
--       vim.api.nvim_win_set_cursor(0, { start.line + 1, start.character })
--     end
--   )
-- end, { desc = 'Open definitions with relative paths.' })
