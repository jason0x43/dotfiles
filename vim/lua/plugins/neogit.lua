require('neogit').setup({
  disable_context_highlighting = true,
})

local util = require('util')
local c = require('util.theme').get_colors()

util.hi('NeogitFoldOpen', { fg=c('fg_sign'), bg=c('bg_sign'), style='bold' })
util.hi('NeogitFoldClosed', { fg=c('fg_sign'), bg=c('bg_sign'), style='bold' })

vim.cmd('sign define NeogitOpen:section texthl=NeogitFoldOpen')
vim.cmd('sign define NeogitClosed:section texthl=NeogitFoldClosed')
vim.cmd('sign define NeogitOpen:item texthl=NeogitFoldOpen')
vim.cmd('sign define NeogitClosed:item texthl=NeogitFoldClosed')
