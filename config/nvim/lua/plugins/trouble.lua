local util = require('util')
require('trouble').setup({})

util.keys.lmap('e', ':TroubleToggle<cr>')

util.augroup('init_trouble', {
  'FileType Trouble setlocal cursorline',
})
