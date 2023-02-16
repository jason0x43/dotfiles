-- flashy status bar
return {
  'nvim-lualine/lualine.nvim',

  dependencies = {
    'arkav/lualine-lsp-progress',
    'nvim-web-devicons',
    -- 'nvim-navic',
  },

  config = function()
    -- local navic = require('nvim-navic')
    local hi = vim.api.nvim_set_hl

    -- make statusline transparent so we don't get a flash before lualine
    -- renders
    hi(0, 'StatusLine', { bg = '' })
    hi(0, 'StatusLineNC', { bg = '' })

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
          {
            'filetype',
            icon_only = 1,
            separator = '',
            padding = { left = 0, right = 0 },
          },
          { 'filename', path = 1, padding = { left = 1, right = 1 } },
        },
        lualine_x = {
          {
            'language_servers',
            padding = { left = 0, right = 0 },
          },
          {
            require('lazy.status').updates,
            cond = require('lazy.status').has_updates,
          },
        },
        lualine_y = {
          { 'progress', padding = { left = 1, right = 0 } },
        },
      },
      extensions = { 'nvim-tree', 'quickfix' },
    }

    require('lualine').setup(config)

    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('lualine.colorizer', {}),
      callback = function()
        require('lualine').setup({
          options = {
            theme = 'wezterm',
          },
        })
      end,
    })
  end,
}
