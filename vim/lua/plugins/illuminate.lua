local util = require('util')
local c = require('config.theme').get_colors()

util.hi('LspReferenceText', { guibg = c('bg_status') })
util.hi('LspReferenceRead', { guibg = c('bg_status') })
util.hi('LspReferenceWrite', { guibg = c('bg_status') })
