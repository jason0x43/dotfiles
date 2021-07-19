local exports = {}

function exports.update_colors()
  local util = require('util')
  local c = require('util.theme').get_colors()

  util.hi('LspReferenceText', { guibg = c('bg_status') })
  util.hi('LspReferenceRead', { guibg = c('bg_status') })
  util.hi('LspReferenceWrite', { guibg = c('bg_status') })
end

exports.update_colors()

require('util').augroup('plugins.illuminate', {
  'ColorScheme * lua require("plugins.illuminate").update_colors()'
})

return exports
