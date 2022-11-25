local M = {}

M.config = function()
  local hi = require('user.util.theme').hi
  local req = require('user.req')

  -- make statusline transparent so we don't get a flash before lualine renders
  hi('StatusLine', { bg = '' })
  hi('StatusLineNC', { bg = '' })

  local refresh_time = 500

  local config = {
    options = {
      theme = 'wezterm',
      section_separators = { left = ' ', right = ' ' },
      component_separators = { left = '│', right = '│' },
      globalstatus = true,
      refresh = {
        -- match refresh time of block containing lsp_progress block to the
        -- lsp_progress timer
        statusline = refresh_time,
      },
    },
    sections = {
      lualine_b = {
        { 'file_status', padding = { left = 0, right = 1 } },
        -- { 'branch', icon = '', padding = { left = 0, right = 1 } },
        { 'diff', padding = { left = 0, right = 1 } },
        {
          'lsp_progress',
          display_components = { 'spinner' },
          spinner_symbols = { '⠦', '⠖', '⠲', '⠴' },
          -- spinner_symbols = { '⠐', '⠠', '⠄', '⠂' },
          timer = { spinner = refresh_time },
          padding = { left = 0, right = 1 },
        },
        {
          'diagnostics',
          sources = { 'nvim_diagnostic' },
          padding = { left = 0, right = 1 },
        },
      },
      lualine_c = {},
      lualine_x = {},
      lualine_y = {
        { 'progress', padding = { left = 1, right = 0 } },
      },
    },
    winbar = {
      lualine_c = {
        { 'filetype', icon_only = 1, separator = '' },
        { 'filename', path = 1, padding = { left = 1, right = 1 }, file_status = false },
      },
      lualine_x = {
        {
          'language_servers',
          separator = '',
          padding = { left = 1, right = 1 },
        },
      },
    },
    extensions = { 'nvim-tree', 'quickfix' },
  }

  config.inactive_winbar = {
    lualine_c = {
      { 'filetype', icon_only = 1 },
      { 'filename', path = 1, padding = { left = 1, right = 1 } },
    },
  }

  local navic = req('nvim-navic')
  if navic then
    table.insert(
      config.sections.lualine_c,
      { navic.get_location, cond = navic.is_available, padding = { left = 0 } }
    )
  end

  local outline = req('symbols-outline')
  if outline then
    table.insert(config.extensions, 'symbols_outline')
  end

  require('lualine').setup(config)
end

return M
