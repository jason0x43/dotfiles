-- disable shadafile while sourcing config
-- https://www.reddit.com/r/neovim/comments/opipij/guide_tips_and_tricks_to_reduce_startup_and/
vim.opt.shadafile = 'NONE'

require('config.packer')
require('config.options')
require('config.keymaps')
require('config.autocommands')
require('config.completion')
require('plugins')
require('theme')
require('packer_compiled')

vim.opt.shadafile = ''
