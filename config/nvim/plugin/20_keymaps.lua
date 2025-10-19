---@param mode string|string[]
---@param key string
---@param command string | fun(): nil
---@param desc string
local function set_key(mode, key, command, desc)
  vim.keymap.set(mode, key, command, { desc = desc })
end

-- Toggle line and column highlighting
set_key('n', '#', function()
  if vim.wo.cursorline and vim.wo.cursorcolumn then
    vim.wo.cursorline = false
    vim.wo.cursorcolumn = false
  elseif vim.wo.cursorline then
    vim.wo.cursorcolumn = true
  else
    vim.wo.cursorline = true
  end
end, 'Toggle line and column highlighting')

-- Space to clear search highlights
set_key('n', '<space>', '<Cmd>set nohlsearch<CR>', 'Clear search highlights')

-- Disable "Entering Ex mode"
set_key('n', 'Q', '<nop>', 'Disable entering Ex mode')

-- Go to the previous buffer
set_key('n', '<leader><leader>', '<C-^>', 'Go to the previous buffer')

set_key(
  'n',
  '<leader>;',
  '<Cmd>lua require("dropbar.api").pick()<CR>',
  'Pick symbols in winbar'
)

set_key(
  'n',
  '[;',
  '<Cmd>lua require("dropbar.api").goto_context_start()<CR>',
  'Go to start of current context'
)

set_key(
  'n',
  '];',
  '<Cmd>lua require("dropbar.api").select_next_context()<CR>',
  'Select next context'
)

set_key(
  'n',
  '<leader>a',
  vim.lsp.buf.code_action,
  'Show a list of possible code actions'
)

set_key('n', '<leader>b', '<Cmd>Pick buffers<CR>', 'Find buffers')

-- Close the current window
set_key('n', '<leader>c', function()
  ---@type boolean, string | nil
  local ok, err = pcall(function()
    vim.cmd('close')
  end)
  if not ok and err and string.match(err, 'E444') then
    vim.cmd('quit')
  end
end, 'Close the current window')

set_key(
  'n',
  '<leader>d',
  '<Cmd>Pick diagnostic scope=current<CR>',
  'List diagnostics'
)

-- Show diagnostics
set_key(
  'n',
  '<leader>D',
  vim.diagnostic.open_float,
  'Show diagnostics for the current line'
)

set_key('n', '<leader>e', function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.getcwd()
  if vim.uv.fs_stat(bufname) then
    dir = vim.fn.fnamemodify(bufname, ':p:h')
  end
  require('mini.files').open(dir)
end, 'Open a file manager')

set_key('n', '<leader>f', '<Cmd>Pick smart<CR>', 'Find files')

set_key('n', '<leader>F', function()
  require('conform').format({ lsp_fallback = true, async = true })
end, 'Format the current file')

set_key(
  'n',
  '<leader>gc',
  '<Cmd>Pick conflicts<CR>',
  'Find files with merge conflictes'
)

set_key(
  'n',
  '<leader>gf',
  '<Cmd>Pick git_files<CR>',
  'Find all git-tracked files'
)

set_key('n', '<leader>gm', '<Cmd>Pick modified<CR>', 'Find modified files')

set_key('n', '<leader>h', '<Cmd>Pick help<CR>', 'Find help')

-- Insert a UUID
set_key('n', '<leader>iu', function()
  local uuid = vim.fn.system('uuidgen')
  uuid = require('user.util.string').trim(uuid)
  uuid = vim.fn.tolower(uuid)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
end, 'Insert a UUID at the cursor position')

-- Insert a capitalized UUID
set_key('n', '<leader>iU', function()
  local uuid = vim.fn.system('uuidgen')
  uuid = require('user.util.string').trim(uuid)
  uuid = vim.fn.toupper(uuid)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
end, 'Insert an all-caps UUID at the cursor position')

set_key(
  'n',
  '<leader>k',
  '<Cmd>lua require("mini.bufremove").delete()<CR>',
  'Close the current buffer'
)

set_key(
  'n',
  '<leader>K',
  '<Cmd>lua require("mini.bufremove").delete(0, true)<CR>',
  'Close the current buffer with prejudice'
)

set_key(
  'n',
  '<leader>li',
  vim.lsp.buf.implementation,
  'Go to the implementation of a symbol'
)

set_key(
  'n',
  '<leader>ll',
  '<Cmd>lua require("user.util.lsp").get_document_location()<CR>',
  'Find help'
)

set_key('n', '<leader>lr', '<Cmd>Pick lsp scope=references<CR>', 'Find help')

set_key(
  'n',
  '<leader>ls',
  '<Cmd>Pick lsp scope=document_symbol<CR>',
  'Find help'
)

set_key('n', '<leader>lS', function()
  local query = vim.fn.input('Symbol query: ')
  require('mini.extra').pickers.lsp({
    scope = 'workspace_symbol',
    symbol_query = query,
  })
end, 'Find help')

set_key(
  'n',
  '<leader>r',
  '<Cmd>Pick recent current_dir=true<CR>',
  'Find recent files'
)

set_key(
  'n',
  '<leader>s',
  '<Cmd>Pick grep_live<CR>',
  'Search for strings in files'
)

set_key(
  'n',
  '<leader>S',
  '<Cmd>lua require("mini.starter").open()<CR>',
  'Open the mini starter screen'
)

set_key('n', '<leader>u', '<Cmd>Pick undotree<CR>', 'List diagnostics')

-- Quit vim
set_key('n', '<leader>q', '<cmd>qall<cr>', 'Exit vim')
set_key('n', '<leader>Q', '<cmd>qall!<cr>', 'Exit vim with prejudice')

-- Save the current file
set_key('n', '<leader>w', '<cmd>w<cr>', 'Save the current file')
set_key('n', '<leader>W', '<cmd>w!<cr>', 'Save all open files')

-- Window movement keys for Windows
if vim.fn.has('win32') ~= 0 then
  set_key(
    { 'n', 'i' },
    '<c-h>',
    '<cmd>wincmd h<cr>',
    'Focus the window to the left'
  )
  set_key({ 'n', 'i' }, '<c-j>', '<cmd>wincmd j<cr>', 'Focus the window below')
  set_key({ 'n', 'i' }, '<c-k>', '<cmd>wincmd k<cr>', 'Focus the window above')
  set_key(
    { 'n', 'i' },
    '<c-l>',
    '<cmd>wincmd l<cr>',
    'Focus the window to the right'
  )
else
  set_key(
    { 'n', 'i' },
    '<c-h>',
    '<Cmd>KittyFocus left<CR>',
    'Focus the window to the left'
  )
  set_key(
    { 'n', 'i' },
    '<c-j>',
    '<Cmd>KittyFocus down<CR>',
    'Focus the window below'
  )
  set_key(
    { 'n', 'i' },
    '<c-k>',
    '<Cmd>KittyFocus up<CR>',
    'Focus the window above'
  )
  set_key(
    { 'n', 'i' },
    '<c-l>',
    '<Cmd>KittyFocus right<CR>',
    'Focus the window to the right'
  )
end

set_key('n', '<leader>y', '<Cmd>Yazi<CR>', 'Open a yazi overlay')

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
