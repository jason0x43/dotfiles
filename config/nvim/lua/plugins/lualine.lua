local theme = require('util.theme')
local c = theme.get_colors()

-- make statusline transparent so we don't get a flash before lualine renders
theme.hi('StatusLine', { bg = '' })
theme.hi('StatusLineNC', { bg = '' })

require('lualine').setup({
  options = {
    theme = 'base16',
    section_separators = { left = ' ', right = ' ' },
    component_separators = { left = '│', right = '│' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { { 'branch', padding = { left = 0 }, icon = '' }, 'diff' },
    lualine_c = {
      {
        'filetype',
        separator = '',
        padding = { left = 0 },
        icon_only = true,
        color = { fg = c('blue') },
      },
      { 'filename', path = 1, padding = { left = 0 } },
    },
    lualine_x = {
      { 'diagnostics', sources = { 'nvim_lsp' } },
      { 'language_servers', separator = '', padding = { right = 0 } },
      {
        'lsp_progress',
        display_components = { 'spinner' },
        colors = { spinner = c('blue') },
        spinner_symbols = { '⠖', '⠲', '⠴', '⠦' },
        timer = { spinner = 250 },
        padding = { left = 1, right = 0 },
      },
    },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
  },
  extensions = { 'nvim-tree', 'quickfix' },
})
