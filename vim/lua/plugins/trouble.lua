local exports = {}

function exports.setup()
  local util = require('util')
  require('trouble').setup({})

  util.keys.lmap('e', ':TroubleToggle<cr>')

  util.augroup('init_trouble', {
    'FileType Trouble setlocal cursorline'
  })
end

return exports
