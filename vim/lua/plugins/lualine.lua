local theme = require('util.theme')
local c = theme.get_colors()

-- make statusline transparent so we don't get a flash before lualine renders
theme.hi('StatusLine', { bg = '' })
theme.hi('StatusLineNC', { bg = '' })

require('lualine').setup({
  options = {
    theme = 'base16',
    section_separators = { ' ', ' ' },
    component_separators = { '│', '│' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { { 'branch', left_padding = 0, icon = '' } },
    lualine_c = {
      {
        'filetype_icon',
        separator = '',
        left_padding = 0,
        color = { fg = c('blue') },
      },
      { 'filename', path = 1, left_padding = 0 },
    },
    lualine_x = {
      { 'diagnostics', sources = { 'nvim_lsp' } },
      { 'language_servers', separator = '', right_padding = 0 },
      {
        'lsp_progress',
        display_components = { 'spinner' },
        colors = { spinner = c('blue') },
        spinner_symbols = { '⠖', '⠲', '⠴', '⠦' },
        timer = { spinner = 250 },
        left_padding = 1,
        right_padding = 0,
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
