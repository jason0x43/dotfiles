require('neogit').setup({
  disable_context_highlighting = true,
})

local theme = require('util.theme')
local c = theme.get_colors()

theme.hi('NeogitFoldOpen', { fg=c('fg_sign'), bg=c('bg_sign'), style='bold' })
theme.hi('NeogitFoldClosed', { fg=c('fg_sign'), bg=c('bg_sign'), style='bold' })

vim.cmd('sign define NeogitOpen:section texthl=NeogitFoldOpen')
vim.cmd('sign define NeogitClosed:section texthl=NeogitFoldClosed')
vim.cmd('sign define NeogitOpen:item texthl=NeogitFoldOpen')
vim.cmd('sign define NeogitClosed:item texthl=NeogitFoldClosed')
