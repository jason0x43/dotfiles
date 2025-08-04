vim.loader.enable()

require('user.config.options')
require('user.config.mini')
require('user.config.autocommands')
require('user.config.theme')
require('user.config.filetypes')
require('user.config.keymaps')
require('user.config.commands')
require('user.config.lsp')

if vim.g.neovide then
    require('user.config.neovide')
end
