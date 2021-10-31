-- disable shadafile while sourcing config
-- https://www.reddit.com/r/neovim/comments/opipij/guide_tips_and_tricks_to_reduce_startup_and/
vim.opt.shadafile = 'NONE'

pcall(require, 'impatient')

require('config.packer_cfg')
require('config.options')
require('config.keymaps')
require('config.autocommands')
require('plugins')
require('theme')

vim.opt.shadafile = ''
