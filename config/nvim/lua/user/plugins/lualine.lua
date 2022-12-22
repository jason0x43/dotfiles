-- flashy status bar
return {
  'nvim-lualine/lualine.nvim',

  dependencies = {
    'arkav/lualine-lsp-progress',
    'kyazdani42/nvim-web-devicons',
  },

  config = function()
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
        lualine_c = {
          { 'filename', path = 1, padding = { left = 1, right = 1 } },
        },
        lualine_x = {
          { 'filetype', icon_only = 1, separator = '', padding = { left = 0 } },
          {
            require('lazy.status').updates,
            cond = require('lazy.status').has_updates,
          },
        },
        lualine_y = {
          { 'progress', padding = { left = 1, right = 0 } },
        },
      },
      winbar = {
        lualine_c = {},
        lualine_x = {
          {
            'language_servers',
            separator = '',
            padding = { left = 1, right = 1 },
          },
        },
      },
      inactive_winbar = {
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

    local navic = req('nvim-navic')
    if navic then
      table.insert(config.winbar.lualine_c, {
        navic.get_location,
        cond = navic.is_available,
        padding = { left = 1 },
      })
    end

    local outline = req('symbols-outline')
    if outline then
      table.insert(config.extensions, 'symbols_outline')
    end

    require('lualine').setup(config)
  end,
}
