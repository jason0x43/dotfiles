require('util').augroup('init_lualine_base16', {
  'ColorScheme * lua require("lualine.themes.base16.util").update_colors()'
})

return require('lualine.themes.base16.util').get_theme()
