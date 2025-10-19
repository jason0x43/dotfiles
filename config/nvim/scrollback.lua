-- remove vim.fn.stdpath('config') from vim.opt.runtimepath to prevent the
-- default user config from loading
vim.opt.runtimepath:remove(vim.fn.stdpath('config'))

-- Just need cterm colors for this
vim.o.termguicolors = false

-- No cmd bar
vim.o.cmdheight = 0

-- No '-- More --' prompts
vim.opt.more = false

-- No line numbering
vim.opt.number = false
vim.opt.relativenumber = false

-- Hide the status line
vim.opt.laststatus = 0
vim.opt.ruler = false
vim.opt.showmode = false

-- Yank to the system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Make 'q' quit
vim.keymap.set({ 'n', 'v' }, 'q', '<cmd>qa!<cr>', { silent = true })

-- Make '/' search backward
vim.keymap.set('n', '/', '?', { noremap = true })

-- Dimmer background for search results
vim.api.nvim_set_hl(0, 'Search', { ctermbg = 8, ctermfg = 15 })
vim.api.nvim_set_hl(0, 'CurSearch', { ctermbg = 5, ctermfg = 0 })
vim.api.nvim_set_hl(0, 'Visual', { ctermbg = 0 })

vim.keymap.set({ 'n', 'i' }, '<c-h>', function()
  require('user.terminal').focus_kitty('left')
end)
vim.keymap.set({ 'n', 'i' }, '<c-j>', function()
  require('user.terminal').focus_kitty('down')
end)
vim.keymap.set({ 'n', 'i' }, '<c-k>', function()
  require('user.terminal').focus_kitty('up')
end)
vim.keymap.set({ 'n', 'i' }, '<c-l>', function()
  require('user.terminal').focus_kitty('right')
end)

-- Jump cursor to proper position when the buffer renders
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Restore the standard runtime path
    vim.opt.runtimepath:append(vim.fn.stdpath('config'))

    -- Make buffer read-only and unmodifiable
    vim.opt_local.modifiable = false
    vim.opt_local.readonly = true

    -- Don't try leave a scroll margin around the cursor
    vim.opt_local.scrolloff = 0
    vim.opt_local.sidescrolloff = 0

    -- Find the last non-empty line
    local last_nonempty = vim.fn.prevnonblank(vim.fn.line('$'))
    vim.api.nvim_win_set_cursor(0, { last_nonempty, 3 })
  end,
})

-- Flash content when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({
      higroup = 'Search',
      timeout = 200,
      on_visual = true,
    })
  end,
})
