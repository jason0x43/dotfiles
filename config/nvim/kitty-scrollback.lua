-- in your Neovim config
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    print('opened!')
    vim.wo.wrap = true
  end,
})

vim.g.mapleader = ';'

-- Add kitty-scrollback.nvim to the runtimepath to allow us to require the
-- kitty-scrollback module. Pick a runtimepath that corresponds with your
-- package manager, if you are not sure leave them all it will not cause any
-- issues.
vim.opt.runtimepath:append(
  vim.fn.stdpath('data') .. '/site/pack/deps/opt/kitty-scrollback.nvim'
)

vim.keymap.set({ 'v' }, 'Y', '<Plug>(KsbVisualYankLine)', {})
vim.keymap.set({ 'v' }, 'y', '<Plug>(KsbVisualYank)', {})
vim.keymap.set({ 'n' }, 'Y', '<Plug>(KsbNormalYankEnd)', {})
vim.keymap.set({ 'n' }, 'y', '<Plug>(KsbNormalYank)', {})
vim.keymap.set({ 'n' }, 'yy', '<Plug>(KsbYankLine)', {})

require('kitty-scrollback').setup({
  keymaps_enabled = false,
})
