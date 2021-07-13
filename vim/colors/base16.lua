local util = require('util')

-- set the theme based on the value specified in ~/.vimrc_background
local theme_file = os.getenv('HOME') .. '/.vimrc_background'
local theme_name = 'ashes'

if vim.fn.filereadable(theme_file) == 1 then
  local lines = vim.fn.readfile(theme_file, '', 1)
  local words = vim.split(lines[1], '%s')
  theme_name = util.trim(words[#words], '\''):sub(8)
end

require('base16').apply_theme(theme_name)
vim.g.colors_name = 'base16'
