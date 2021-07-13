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
    a = { fg = colors.base0, bg = colors.base2 },
  }
}

local function language_servers()
  local clients = vim.lsp.buf_get_clients()
  local client_names = {}

  for _, client in pairs(clients) do
    table.insert(client_names, client.name)
  end

  if not vim.tbl_isempty(client_names) then
    return table.concat(client_names, ', ')
  end

  return ''
end

local function filetype_icon()
  local devicons = require('nvim-web-devicons')
  return devicons.get_icon(vim.fn.expand('%:t'), vim.fn.expand('%:e'))
end

-- add round edges to a status bar
-- the given section is mutated and returned
local function edgify(section, edge, opts)
  local char = ''
  if edge == 'right' then
    char = ''
  end

  local edge_config = {
    function()
      return char
    end,
    left_padding = 0,
    right_padding = 0,
    separator = '',
    color = { gui = 'inverse' }
  }

  if opts ~= nil then
    edge_config = util.assign(edge_config, opts)
  end

  if edge == 'left' then
    -- remove the first component, add the round cap, the re-add the first
    -- component with its left padding removed
    local first = table.remove(section, 1)
    table.insert(section, 1, edge_config)
    if type(first) ~= 'table' then
      first = { first }
    end
    first.left_padding = 0
    table.insert(section, 2, first)
  else
    -- remove the last component, re-add it with its right padding removed,
    -- then add an end cap
    local last = table.remove(section)
    if type(last) ~= 'table' then
      last = { last }
    end
    last.right_padding = 0
    last.separator = ''
    table.insert(section, last)
    table.insert(section, edge_config)
  end

  return section
end

-- make statusline transparent so we don't get a flash before lualine renders
util.hi('StatusLine', { guibg = '', ctermbg = '' })
util.hi('StatusLineNC', { guibg = '', ctermbg = '' })

-- add round edges to quickfix extension
local quickfix = require('lualine.extensions.quickfix')
edgify(quickfix.sections.lualine_a, 'left')
edgify(quickfix.sections.lualine_z, 'right')

-- add round edges to tree extension
local tree = require('lualine.extensions.nvim-tree')
edgify(tree.sections.lualine_a, 'left')
tree.sections.lualine_x = edgify(
  {
    function()
      return ' '
    end
  }, 'right', { color = { fg = colors.base1, bg = colors.base0 } }
)

require('lualine').setup(
  {
    options = {
      theme = base16_theme,
      section_separators = { ' ', ' ' },
      component_separators = { '│', '│' }
    },
    sections = {
      lualine_a = edgify({ 'mode' }, 'left'),
      lualine_b = { { 'branch', left_padding = 0, icon = '' } },
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
      },
      lualine_z = edgify({ 'location' }, 'right')
    },
    inactive_sections = {
      lualine_c = edgify(
        { 'filename' }, 'left',
          { color = { fg = colors.base1, bg = colors.base0 } }
      ),
      lualine_x = edgify(
        { 'location' }, 'right',
          { color = { fg = colors.base1, bg = colors.base0 } }
      )
    },
    extensions = { 'nvim-tree', 'quickfix' }
  }
)
