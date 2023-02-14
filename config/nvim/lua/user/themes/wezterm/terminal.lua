local theme_util = require('user.util.theme')
local shift = theme_util.shift

local M = {}

function M.apply(colors)
  print('Applying terminal theme')

  local bg = colors.bg
  local fg = colors.fg
  local color00 = colors.color00
  local color01 = colors.color01
  local color02 = colors.color02
  local color03 = colors.color03
  local color04 = colors.color04
  local color05 = colors.color05
  local color06 = colors.color06
  local color07 = colors.color07
  local color08 = colors.color08
  local color09 = colors.color09
  local color10 = colors.color10
  local color11 = colors.color11
  local color12 = colors.color12
  local color13 = colors.color13
  local color14 = colors.color14
  local color15 = colors.color15

  local sign_col_bg = shift(bg, -0.1)

  local hi = vim.api.nvim_set_hl

  hi(0, 'Conceal', { fg = color07, bg = color07 })
  hi(0, 'Constant', { fg = color01 })
  hi(0, 'CursorColumn', { bg = color07 })
  hi(0, 'CursorLine', { underline = true })
  hi(0, 'Delimiter', { fg = color04, underline = true })
  hi(0, 'DiffAdd', { fg = color00, bg = color02 })
  hi(0, 'DiffChange', { fg = color00, bg = color03 })
  hi(0, 'DiffDelete', { fg = color00, bg = color01 })
  hi(0, 'DiffText', { fg = color00, bg = color11, bold = true })
  hi(0, 'Directory', { fg = color04 })
  hi(0, 'Error', { fg = color15, bg = color09 })
  hi(0, 'ErrorMsg', { fg = color15, bg = color01 })
  hi(0, 'Identifier', { fg = color06 })
  hi(0, 'Ignore', { fg = color15 })
  hi(0, 'IncSearch', { reverse = true })
  hi(0, 'MatchParen', { bg = color14 })
  hi(0, 'ModeMsg', { bold = true })
  hi(0, 'MoreMsg', { fg = color02 })
  hi(0, 'NonText', { fg = color12 })
  hi(0, 'Normal', { fg = fg, bg = bg })
  hi(0, 'PmenuSbar', { bg = color08 })
  hi(0, 'PmenuThumb', { bg = color00 })
  hi(0, 'PreProc', { fg = color05 })
  hi(0, 'Question', { fg = color02 })
  hi(0, 'Search', { fg = color00, bg = color11 })
  hi(0, 'Special', { fg = color05 })
  hi(0, 'SpecialKey', { fg = color04 })
  hi(0, 'SpellBad', { fg = color09 })
  hi(0, 'SpellLocal', { bg = color14 })
  hi(0, 'SpellRare', { bg = color13 })
  hi(0, 'Statement', { fg = color03 })
  hi(0, 'TabLine', { fg = color00, bg = color07, underline = true })
  hi(0, 'TabLineFill', { reverse = true })
  hi(0, 'TabLineSel', { bold = true })
  hi(0, 'TermCursor', { reverse = true })
  hi(0, 'Title', { fg = color05 })
  hi(0, 'Todo', { fg = color00, bg = color11 })
  hi(0, 'Type', { fg = color02 })
  hi(0, 'Underlined', { fg = color05, underline = true })
  hi(0, 'Visual', { reverse = true })
  hi(0, 'WarningMsg', { fg = color01 })
  hi(0, 'WildMenu', { fg = color00, bg = color11 })
  hi(0, 'ColorColumn', { bg = sign_col_bg })
  hi(0, 'Comment', { fg = color08, italic = true })
  hi(0, 'CursorLineNr', { fg = color08 })
  hi(0, 'FoldColumn', { fg = color08, bg = color07 })
  hi(0, 'Folded', { fg = color08, bg = color07 })
  hi(0, 'LineNr', { fg = shift(fg, 0.5), bg = sign_col_bg })
  hi(0, 'Pmenu', { fg = color00, bg = color07 })
  hi(0, 'PmenuSel', { fg = color07, bg = color00 })
  hi(0, 'SignColumn', { fg = color07, bg = sign_col_bg })
  hi(0, 'SpellCap', { fg = color08, bg = color07 })
  hi(0, 'StatusLine', { fg = color00, bg = color07, bold = true })
  hi(0, 'StatusLineNC', { fg = color08, bg = color07 })
  hi(0, 'VertSplit', { fg = color08, bg = color07 })

  -- gitsigns
  hi(0, 'GitSignsAdd', { fg = color02, bg = sign_col_bg })
  hi(0, 'GitSignsChange', { fg = color04, bg = sign_col_bg })
  hi(0, 'GitSignsDelete', { fg = color01, bg = sign_col_bg })
end

return M
