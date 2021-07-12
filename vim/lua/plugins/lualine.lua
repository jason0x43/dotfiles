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
    c = { fg = colors.base6, bg = colors.base1 }
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

local progress = {
  'lsp_progress',
  -- display_components = { 'lsp_client_name', { 'title', 'percentage', 'message' } },
  -- With spinner
  -- display_components = { 'lsp_client_name', 'spinner', { 'title', 'percentage', 'message' }},
  colors = {
    percentage = colors.cyan,
    title = colors.cyan,
    message = colors.cyan,
    spinner = colors.cyan,
    lsp_client_name = colors.magenta,
    use = true
  },
  separators = {
    component = ' ',
    progress = ' | ',
    -- message = { pre = '(', post = ')' },
    percentage = { pre = '', post = '%% ' },
    title = { pre = '', post = ': ' },
    lsp_client_name = { pre = '[', post = ']' },
    spinner = { pre = '', post = '' },
    message = { commenced = 'In Progress', completed = 'Completed' }
  },
  display_components = {
    'lsp_client_name',
    'spinner',
    { 'title', 'percentage', 'message' }
  },
  -- timer = {
  --   progress_enddelay = 500,
  --   spinner = 1000,
  --   lsp_client_name_enddelay = 1000
  -- },
  spinner_symbols = {
    '🌑 ',
    '🌒 ',
    '🌓 ',
    '🌔 ',
    '🌕 ',
    '🌖 ',
    '🌗 ',
    '🌘 '
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

  if msg ~= '' then
    return ' ' .. msg
  end
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
        { 'filename', path = 1 }
      },
      lualine_x = {
        'lsp_progress',
        { 'diagnostics', sources = { 'nvim_lsp' } },
        { 'filetype', colored = false },
        language_servers
      }
    },
    inactive_sections = { lualine_c = { 'filename' }, lualine_x = {} },
    extensions = { 'fzf' }
  }
)
