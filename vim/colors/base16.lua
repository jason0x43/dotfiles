local util = require('util')

-- set the theme based on the value specified in ~/.vimrc_background
local theme_file = util.home .. '/.vimrc_background'
if vim.fn.filereadable(theme_file) then
  local lines = vim.fn.readfile(theme_file, '', 1)
  local words = vim.split(lines[1], '%s')
  local name = util.trim(words[#words], '\''):sub(8)
  local b16 = require('base16')
  require('base16').apply_theme(name)
  vim.g.colors_name = 'base16'
end
