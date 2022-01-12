local c = require('user.util.theme').get_colors()

return {
  normal = {
    a = { fg = c('bg'), bg = c('blue'), gui = 'bold' },
    b = { fg = c('fg_status'), bg = c('bg_status', -0.1) },
    c = { fg = c('fg_status'), bg = c('bg_status') },
  },

  insert = { a = { fg = c('bg'), bg = c('green'), gui = 'bold' } },

  visual = { a = { fg = c('bg'), bg = c('purple'), gui = 'bold' } },

  replace = { a = { fg = c('bg'), bg = c('red'), gui = 'bold' } },

  inactive = {
    a = { fg = c('bg'), bg = c('selection') },
  },
}
