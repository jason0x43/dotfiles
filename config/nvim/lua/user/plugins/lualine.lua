local M = {}

M.config = function()
  local theme = require('user.util.theme')
  local req = require('user.req')

  -- make statusline transparent so we don't get a flash before lualine renders
  theme.hi('StatusLine', { bg = '' })
  theme.hi('StatusLineNC', { bg = '' })

  local config = {
    options = {
      theme = 'selenized',
      section_separators = { left = ' ', right = ' ' },
      component_separators = { left = '│', right = '│' },
      globalstatus = true,
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        {
          'filetype',
          separator = '',
          padding = { left = 0, right = 1 },
          icon_only = true,
        },
      },
      lualine_c = {
        { 'filename', path = 1, padding = { left = 0, right = 1 } },
      },
      lualine_x = {
        { 'diagnostics', sources = { 'nvim_diagnostic' } },
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
  }

  local navic = req('nvim-navic')
  if navic then
    table.insert(
      config.sections.lualine_c,
      { navic.get_location, cond = navic.is_available }
    )
  end

  local outline = req('symbols-outline')
  if outline then
    table.insert(config.extensions, 'symbols_outline')
  end

  require('lualine').setup(config)
end

return M
