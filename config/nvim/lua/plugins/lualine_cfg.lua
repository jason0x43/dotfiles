local theme = require('util.theme')

local status, gps = pcall(require, 'nvim-gps')
if not status then
  gps = {
    get_location = function()
      return {}
    end,
    is_available = function()
      return false
    end,
  }
end

-- make statusline transparent so we don't get a flash before lualine renders
theme.hi('StatusLine', { bg = '' })
theme.hi('StatusLineNC', { bg = '' })

require('lualine').setup({
  options = {
    theme = 'selenized',
    section_separators = { left = ' ', right = ' ' },
    component_separators = { left = '│', right = '│' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      { 'branch', padding = { left = 0, right = 1 }, icon = '' },
      'diff',
    },
    lualine_c = {
      {
        'filetype',
        separator = '',
        padding = { left = 0, right = 1 },
        icon_only = true,
      },
      { 'filename', path = 1, padding = { left = 0, right = 1 } },
      { gps.get_location, cond = gps.is_available }
    },
    lualine_x = {
      { 'diagnostics', sources = { 'nvim_lsp' } },
      {
        'language_servers',
        separator = '',
        padding = { right = 0, left = 1 },
      },
      {
        'lsp_progress',
        display_components = { 'spinner' },
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
  extensions = { 'nvim-tree', 'quickfix', 'symbols_outline' },
})
