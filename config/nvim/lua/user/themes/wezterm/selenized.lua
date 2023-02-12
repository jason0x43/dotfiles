local theme_util = require('user.util.theme')
local hi = theme_util.hi
local hi_link = theme_util.hi_link

local M = {}

function M.apply(palette)
  local bg_0 = palette.color16
  local bg_1 = palette.color00
  local bg_2 = palette.color08
  local blue = palette.color04
  local br_blue = palette.color13
  local br_cyan = palette.color15
  local br_green = palette.color11
  local br_magenta = palette.color14
  local br_orange = palette.color19
  local br_red = palette.color10
  local br_violet = palette.color21
  local br_yellow = palette.color12
  local cyan = palette.color06
  local dim_0 = palette.color07
  local fg_0 = palette.color17
  local fg_1 = palette.color16
  local green = palette.color02
  local magenta = palette.color05
  local orange = palette.color18
  local red = palette.color01
  local violet = palette.color20
  local yellow = palette.color03

  local sign_col_bg = ''

  -- link groups
  hi_link('Boolean', 'Constant')
  hi_link('Character', 'Constant')
  hi_link('Conditional', 'Statement')
  hi_link('Debug', 'Special')
  hi_link('Define', 'PreProc')
  hi_link('Exception', 'Statement')
  hi_link('Float', 'Constant')
  hi_link('FloatBorder', 'NormalFloat')
  hi_link('Include', 'PreProc')
  hi_link('Keyword', 'Statement')
  hi_link('Label', 'Statement')
  hi_link('Macro', 'PreProc')
  hi_link('Number', 'Constant')
  hi_link('Operator', 'Statement')
  hi_link('PreCondit', 'PreProc')
  hi_link('QuickFixLine', 'Search')
  hi_link('Repeat', 'Statement')
  hi_link('SpecialChar', 'Special')
  hi_link('SpecialComment', 'Special')
  hi_link('StatusLineTerm', 'StatusLine')
  hi_link('StatusLineTermNC', 'StatusLineNC')
  hi_link('StorageClass', 'Type')
  hi_link('String', 'Constant')
  hi_link('Structure', 'Type')
  hi_link('Tag', 'Special')
  hi_link('Typedef', 'Type')
  hi_link('lCursor', 'Cursor')
  hi_link('ErrorMsg', 'Error')
  hi_link('MatchParen', 'MatchBackground')

  -- basic groups
  hi('Normal', fg_0, bg_0, '', '')
  hi('NormalNC', dim_0, bg_0)
  hi('Comment', dim_0, '', 'italic', '')
  hi('Constant', cyan, '', '', '')
  hi('Delimiter', fg_0, '', '', '')
  hi('Function', br_blue, '', '', '')
  hi('Identifier', violet, '', '', '')
  hi('Statement', yellow, '', '', '')
  hi('PreProc', orange, '', '', '')
  hi('Type', green, '', '', '')
  hi('Special', orange, '', 'bold', '')
  hi('Underlined', violet, '', 'underline', '')
  hi('Ignore', bg_2, '', '', '')
  hi('Error', red, '', 'bold', '')
  hi('Todo', magenta, '', 'bold', '')

  -- extended groups
  hi('ColorColumn', '', bg_1, '', '')
  hi('Conceal', '', '', '', '')
  hi('Cursor', '', '', 'reverse', '')
  hi('CursorColumn', '', bg_1, '', '')
  hi('CursorLine', '', bg_1, '', '')
  hi('CursorLineNr', fg_1, '', '', '')
  hi('DiagnosticHint', dim_0)
  hi('DiagnosticSignHint', dim_0, sign_col_bg)
  hi('DiagnosticWarn', orange)
  hi('DiagnosticSignWarn', orange, sign_col_bg)
  hi('DiagnosticError', red)
  hi('DiagnosticSignError', red, sign_col_bg)
  hi('DiagnosticInfo', br_blue)
  hi('DiagnosticSignInfo', br_blue, sign_col_bg)
  hi('DiagnosticUnderlineError', { gui = 'undercurl', sp = red })
  hi('DiagnosticUnderlineHint', { gui = 'undercurl', sp = dim_0 })
  hi('DiagnosticUnderlineWarn', { gui = 'undercurl', sp = orange })
  hi('DiagnosticUnderlineInfo', { gui = 'undercurl', sp = br_blue })
  hi('DiffAdd', green, bg_1, '', '')
  hi('DiffChange', yellow, bg_1, '', '')
  hi('DiffDelete', red, bg_1, '', '')
  hi('DiffText', bg_1, yellow, '', '')
  hi('Directory', '', '', '', '')
  hi('EndOfBuffer', '', '', '', '')
  hi('FoldColumn', '', '', '', '')
  hi('Folded', '', bg_1, '', '')
  hi('IncSearch', orange, '', 'reverse', '')
  hi('LineNr', bg_2, sign_col_bg, '', '')
  hi('LspReferenceRead', nil, bg_1)
  hi('LspReferenceText', nil, bg_1)
  hi('LspReferenceWrite', nil, bg_1)
  hi('ModeMsg', '', '', '', '')
  hi('MoreMsg', '', '', '', '')
  hi('NonText', '', '', '', '')
  hi('NormalFloat', '', bg_0, '', '')
  hi('Pmenu', fg_0, bg_1, '', '')
  hi('PmenuSbar', '', bg_2, '', '')
  hi('PmenuSel', '', bg_2, '', '')
  hi('PmenuThumb', '', dim_0, '', '')
  hi('Question', '', '', '', '')
  hi('RubyDefine', fg_1, '', 'bold', '')
  hi('Search', yellow, '', 'reverse', '')
  hi('SignColumn', '', sign_col_bg, '', '')
  hi('SpecialKey', '', '', '', '')
  hi('SpellBad', '', '', 'undercurl', red)
  hi('SpellCap', '', '', 'undercurl', red)
  hi('SpellLocal', '', '', 'undercurl', yellow)
  hi('SpellRare', '', '', 'undercurl', cyan)
  hi('StatusLine', '', '', 'reverse', '')
  hi('StatusLineNC', '', bg_2, '', '')
  hi('TabLine', dim_0, '', 'reverse', '')
  hi('TabLineFill', dim_0, '', 'reverse', '')
  hi('TabLineSel', fg_1, bg_1, 'bold,reverse', '')
  hi('Terminal', '', '', '', '')
  hi('Title', orange, '', 'bold', '')
  hi('ToolbarButton', '', '', 'reverse', '')
  hi('ToolbarLine', '', bg_2, '', '')
  hi('VertSplit', dim_0, bg_0, '')
  hi('VimCommand', yellow, '', '', '')
  hi('Visual', '', bg_2, '', '')
  hi('VisualNOS', '', '', '', '')
  hi('WarningMsg', '', '', '', '')
  hi('WildMenu', '', '', '', '')
  hi('diffAdded', green, '', '', '')
  hi('diffRemoved', red, '', '', '')
  hi('diffOldFile', br_red, '', '', '')
  hi('diffNewFile', br_green, '', '', '')
  hi('diffFile', blue, '', '', '')

  -- override some of the default treesitter links
  hi_link('TSConstBuiltin', 'Constant')
  hi_link('TSConstMacro', 'Constant')
  hi_link('TSFuncBuiltin', 'Function')
  hi_link('TSConstructor', 'Function')
  hi_link('@tag', 'Statement')
  hi_link('@tag.delimiter', 'Delimiter')
  hi_link('@tag.attribute', 'Type')
  hi_link('@operator', 'PreProc')
  hi_link('@string', 'Constant')
  hi_link('@variable', 'Identifier')
  hi_link('@keyword', 'Keyword')

  -- TypeScript
  hi_link('typescriptBraces', 'Delimiter')
  hi_link('typescriptParens', 'Delimiter')

  -- JavaScript
  hi_link('javascriptBraces', 'Delimiter')
  hi_link('javascriptParens', 'Delimiter')

  -- Markdown
  hi_link('markdownCodeDelimiter', 'PreProc')
  hi('markdownCode', orange, bg_1)

  -- Startify
  hi('StartifyHeader', green)
  hi('StartifyFile', blue)

  -- devicons
  hi('DevIconBash', green)
  hi('DevIconBat', green)
  hi('DevIconJson', yellow)

  -- gitsigns
  hi('GitSignsAdd', green, sign_col_bg)
  hi('GitSignsChange', yellow, sign_col_bg)
  hi('GitSignsDelete', red, sign_col_bg)

  -- telescope
  hi_link('LspDiagnosticsDefaultHint', 'DiagnosticHint')
  hi_link('LspDiagnosticsDefaultInformation', 'DiagnosticInfo')
  hi_link('LspDiagnosticsDefaultWarning', 'DiagnosticWarn')
  hi_link('LspDiagnosticsDefaultError', 'DiagnosticError')
  hi_link('LspDiagnosticsSignHint', 'DiagnosticSignHint')
  hi_link('LspDiagnosticsSignInformation', 'DiagnosticSignInfo')
  hi_link('LspDiagnosticsSignWarning', 'DiagnosticSignWarn')
  hi_link('LspDiagnosticsSignError', 'DiagnosticSignError')

  -- neotree
  hi_link('NeoTreeFloatBorder', 'Normal')
end

return M
