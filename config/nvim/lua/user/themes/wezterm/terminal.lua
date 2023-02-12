local theme_util = require('user.util.theme')
local hi = theme_util.hi
local shift = theme_util.shift

local M = {}

function M.apply(palette)
	print('Applying terminal theme')

	local bg = palette.bg
	local fg = palette.fg
  local color00 = palette.color00
  local color01 = palette.color01
  local color02 = palette.color02
  local color03 = palette.color03
  local color04 = palette.color04
  local color05 = palette.color05
  local color06 = palette.color06
  local color07 = palette.color07
  local color08 = palette.color08
  local color09 = palette.color09
  local color10 = palette.color10
  local color11 = palette.color11
  local color12 = palette.color12
  local color13 = palette.color13
  local color14 = palette.color14
  local color15 = palette.color15

  local sign_col_bg = shift(bg, -0.1)

	hi('Conceal', color07, color07, '', '')
	hi('Constant', color01, '', '', '')
	hi('CursorColumn', '', color07, '', '')
	hi('CursorLine', '', '', 'underline', '')
	hi('DiffAdd', color00, color02, '', '')
	hi('DiffChange', color00, color03, '', '')
	hi('DiffDelete', color00, color01, '', '')
	hi('DiffText', color00, color11, 'bold', '')
	hi('Directory', color04, '', '' ,'')
	hi('Error', color15, color09, '', '')
	hi('ErrorMsg', color15, color01, '', '')
	hi('Identifier', color06, '', '', '')
	hi('Ignore', color15, '', '', '')
	hi('IncSearch', '', '', 'reverse', '')
	hi('MatchParen', '', color14, '', '')
	hi('ModeMsg', '', '', 'bold', '')
	hi('MoreMsg', color02, '', '', '')
	hi('NonText', color12, '', '', '')
	hi('Normal', fg, bg, '', '')
	hi('PmenuSbar', '', color08, '', '')
	hi('PmenuThumb', '', color00, '', '')
	hi('PreProc', color05, '', '', '')
	hi('Question', color02, '', '', '')
	hi('Search', color00, color11, '', '')
	hi('Special', color05, '', '', '')
	hi('SpecialKey', color04, '', '', '')
	hi('SpellBad', '', color09, '', '')
	hi('SpellLocal', '', color14, '', '')
	hi('SpellRare', '', color13, '', '')
	hi('Statement', color03, '', '', '')
	hi('TabLine', color00, color07, 'underline', '')
	hi('TabLineFill', '', '', 'reverse', '')
	hi('TabLineSel', '', '', 'bold', '')
	hi('TermCursor', '', '', 'reverse', '')
	hi('Title', color05, '', '', '')
	hi('Todo', color00, color11, '', '')
	hi('Type', color02, '', '', '')
	hi('Underlined', color05, '', 'underline', '')
	hi('Visual', '', '', 'inverse', '')
	hi('WarningMsg', color01, '', '', '')
	hi('WildMenu', color00, color11, '', '')
  hi('ColorColumn', '', sign_col_bg, '', '')
  hi('Comment', color07, '', '', '')
  hi('CursorLineNr', color08, '', '', '')
  hi('FoldColumn', color08, color07, '', '')
  hi('Folded', color08, color07, '', '')
  hi('LineNr', shift(fg, 0.5), sign_col_bg, '', '')
  hi('Pmenu', color00, color07, '', '')
  hi('PmenuSel', color07, color00, '', '')
  hi('SignColumn', color07, sign_col_bg, '', '')
  hi('SpellCap', color08, color07, '', '')
  hi('StatusLine', color00, color07, 'bold', '')
  hi('StatusLineNC', color08, color07, '', '')
  hi('VertSplit', color08, color07, '', '')

  -- gitsigns
  hi('GitSignsAdd', color02, sign_col_bg, '', '')
  hi('GitSignsChange', color04, sign_col_bg, '', '')
  hi('GitSignsDelete', color01, sign_col_bg, '', '')
end

return M

