local c = require('config.theme').get_colors()
local exports = {}

exports.normal = {
  a = { fg = c('bg'), bg = c('blue'), gui = 'bold' },
  b = { fg = c('bg'), bg = c('dark_gray') },
  c = { fg = c('fg_status'), bg = c('bg_status') },
}

exports.insert = { a = { fg = c('bg'), bg = c('green'), gui = 'bold' } }

exports.visual = { a = { fg = c('bg'), bg = c('purple'), gui = 'bold' } }

exports.replace = { a = { fg = c('bg'), bg = c('red'), gui = 'bold' } }

exports.inactive = {
  a = { fg = c('bg'), bg = c('selection') },
}

return exports
