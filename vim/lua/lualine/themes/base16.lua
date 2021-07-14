local theme = require('config.theme')
local exports = {}

local c = theme.get_colors()
local darken = theme.darken

exports.normal = {
  a = { fg = c('bg'), bg = c('blue'), gui = 'bold' },
  b = { fg = c('fg_status'), bg = darken(c('bg_status'), 0.075) },
  c = { fg = c('fg_status'), bg = c('bg_status') },
}

exports.insert = { a = { fg = c('bg'), bg = c('green'), gui = 'bold' } }

exports.visual = { a = { fg = c('bg'), bg = c('purple'), gui = 'bold' } }

exports.replace = { a = { fg = c('bg'), bg = c('red'), gui = 'bold' } }

exports.inactive = {
  a = { fg = c('bg'), bg = c('selection') },
}

return exports
