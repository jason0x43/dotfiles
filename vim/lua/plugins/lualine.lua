local g = vim.g

local colors = {
  -- the color names are based on base16_ashes
  base0 = '#' .. g.base16_gui00, -- black
  base1 = '#' .. g.base16_gui01, -- darker gray
  base2 = '#' .. g.base16_gui02, -- dark gray
  base3 = '#' .. g.base16_gui03, -- gray
  base4 = '#' .. g.base16_gui04, -- light gray
  base5 = '#' .. g.base16_gui05, -- lighter gray
  base6 = '#' .. g.base16_gui06, -- lightest gray
  base7 = '#' .. g.base16_gui07, -- white
  base8 = '#' .. g.base16_gui08, -- orange
  base9 = '#' .. g.base16_gui09, -- yellow
  baseA = '#' .. g.base16_gui0A, -- green
  baseB = '#' .. g.base16_gui0B, -- teal
  baseC = '#' .. g.base16_gui0C, -- blue
  baseD = '#' .. g.base16_gui0D, -- purple
  baseE = '#' .. g.base16_gui0E, -- red
  baseF = '#' .. g.base16_gui0F -- brown
}

local base16_theme = {
  normal = {
    a = { fg = colors.base0, bg = colors.baseC, gui = 'bold' },
    b = { fg = colors.base0, bg = colors.base2 },
    c = { fg = colors.base4, bg = colors.base1 }
  },
  insert = { a = { fg = colors.base0, bg = colors.baseA, gui = 'bold' } },
  visual = { a = { fg = colors.base0, bg = colors.baseD, gui = 'bold' } },
  replace = { a = { fg = colors.base0, bg = colors.baseE, gui = 'bold' } },
  inactive = {
    a = { fg = colors.base6, bg = colors.base5, gui = 'bold' },
    b = { fg = colors.base5, bg = colors.base0 },
    c = { fg = colors.base3, bg = colors.base1 }
  }
}

local function language_servers()
  local msg = ''
  local buf_ft = vim.bo.filetype
  local clients = vim.lsp.get_active_clients()

  if not vim.tbl_isempty(clients) then
    local lsps = {}
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.tbl_contains(filetypes, buf_ft) then
        table.insert(lsps, client.name)
      end
    end

    if #lsps > 0 then
      msg = table.concat(lsps, ', ')
    end
  end

  return msg
end

local function filetype_icon()
  local devicons = require('nvim-web-devicons')
  return devicons.get_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))
end

require('lualine').setup(
  {
    options = {
      theme = base16_theme,
      section_separators = { ' ', ' ' },
      component_separators = { '│', '│' }
    },
    sections = {
      lualine_c = {
        {
          filetype_icon,
          separator = '',
          left_padding = 0,
          color = { fg = colors.baseC }
        },
        { 'filename', path = 1, left_padding = 0 }
      },
      lualine_x = {
        { 'diagnostics', sources = { 'nvim_lsp' } },
        { language_servers, icon = '', separator = '', right_padding = 0 },
        {
          'lsp_progress',
          display_components = { 'spinner' },
          colors = { spinner = colors.baseC },
          spinner_symbols = { '⠖', '⠲', '⠴', '⠦' },
          timer = { spinner = 250 },
          left_padding = 1,
          right_padding = 0
        }
      }
    },
    inactive_sections = { lualine_c = { 'filename' }, lualine_x = {} },
    extensions = { 'fzf', 'nvim-tree', 'quickfix', 'fugitive' }
  }
)
