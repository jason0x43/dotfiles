local exports = {}

function exports.update_colors()
  local theme = require('util.theme')
  local c = theme.get_colors()

  theme.hi('LspReferenceText', { guibg = c('bg_status') })
  theme.hi('LspReferenceRead', { guibg = c('bg_status') })
  theme.hi('LspReferenceWrite', { guibg = c('bg_status') })
end

exports.update_colors()

require('util').augroup('plugins.illuminate', {
  'ColorScheme * lua require("plugins.illuminate").update_colors()'
})

return exports
