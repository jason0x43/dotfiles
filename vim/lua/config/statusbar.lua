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
  baseF = '#' .. g.base16_gui0F, -- brown
}

local base16_theme = {
  normal = {
    a = { fg = colors.base0, bg = colors.baseC, gui = 'bold' },
    b = { fg = colors.base7, bg = colors.base2 },
    c = { fg = colors.base6, bg = colors.base1 }
  },
  insert = {
    a = { fg = colors.base0, bg = colors.baseA, gui = 'bold' }
  },
  visual = {
    a = { fg = colors.base0, bg = colors.baseD, gui = 'bold' }
  },
  replace = {
    a = { fg = colors.base0, bg = colors.baseE, gui = 'bold' }
  },
  inactive = {
    a = { fg = colors.base6, bg = colors.base5, gui = 'bold' },
    b = { fg = colors.base5, bg = colors.base0 },
    c = { fg = colors.base6, bg = colors.base0 }
  }
}

require('lualine').setup({
  options = { theme = base16_theme }
})
