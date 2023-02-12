local hi = require('user.util.theme').hi

local M = {}

function M.apply(palette)
  local gui00 = palette.color00
  local gui01 = palette.color18 or palette.color08
  local gui02 = palette.color19 or palette.color11
  local gui03 = palette.color08
  local gui04 = palette.color20 or palette.color12
  local gui05 = palette.color07
  local gui06 = palette.color21 or palette.color13
  local gui07 = palette.color15
  local gui08 = palette.color01
  local gui09 = palette.color16 or palette.color09
  local gui0A = palette.color03
  local gui0B = palette.color02
  local gui0C = palette.color06
  local gui0D = palette.color04
  local gui0E = palette.color05
  local gui0F = palette.color17 or palette.color14

	local sign_col_bg = gui01

  hi('Normal', gui05, gui00, '', '')
  hi('Bold', '', '', 'bold', '')
  hi('Debug', gui08, '', '', '')
  hi('Directory', gui0D, '', '', '')
  hi('Error', gui00, gui08, '', '')
  hi('ErrorMsg', gui08, gui00, '', '')
  hi('Exception', gui08, '', '', '')
  hi('FoldColumn', gui0C, gui01, '', '')
  hi('Folded', gui03, gui01, '', '')
  hi('IncSearch', gui01, gui09, 'none', '')
  hi('Italic', '', '', 'none', '')
  hi('Macro', gui08, '', '', '')
  hi('MatchParen', '', gui03, '', '')
  hi('ModeMsg', gui0B, '', '', '')
  hi('MoreMsg', gui0B, '', '', '')
  hi('Question', gui0D, '', '', '')
  hi('Search', gui01, gui0A, '', '')
  hi('Substitute', gui01, gui0A, 'none', '')
  hi('SpecialKey', gui03, '', '', '')
  hi('TooLong', gui08, '', '', '')
  hi('Underlined', gui08, '', '', '')
  hi('Visual', '', gui02, '', '')
  hi('VisualNOS', gui08, '', '', '')
  hi('WarningMsg', gui08, '', '', '')
  hi('WildMenu', gui08, gui0A, '', '')
  hi('Title', gui0D, '', 'none', '')
  hi('Conceal', gui0D, gui00, '', '')
  hi('Cursor', gui00, gui05, '', '')
  hi('NonText', gui03, '', '', '')
  hi('LineNr', gui03, sign_col_bg, '', '')
  hi('SignColumn', gui03, sign_col_bg, '', '')
  hi('StatusLine', gui04, gui02, 'none', '')
  hi('StatusLineNC', gui03, gui01, 'none', '')
  hi('VertSplit', gui02, gui02, 'none', '')
  hi('ColorColumn', '', gui01, 'none', '')
  hi('CursorColumn', '', gui01, 'none', '')
  hi('CursorLine', '', gui01, 'none', '')
  hi('CursorLineNr', gui04, sign_col_bg, '', '')
  hi('QuickFixLine', '', gui01, 'none', '')
  hi('PMenu', gui05, gui01, 'none', '')
  hi('PMenuSel', gui01, gui05, '', '')
  hi('TabLine', gui03, gui01, 'none', '')
  hi('TabLineFill', gui03, gui01, 'none', '')
  hi('TabLineSel', gui0B, gui01, 'none', '')

  -- Standard syntax highlighting
  hi('Boolean', gui09, '', '', '')
  hi('Character', gui08, '', '', '')
  hi('Comment', gui03, '', '', '')
  hi('Conditional', gui0E, '', '', '')
  hi('Constant', gui09, '', '', '')
  hi('Define', gui0E, '', 'none', '')
  hi('Delimiter', gui0F, '', '', '')
  hi('Float', gui09, '', '', '')
  hi('Function', gui0D, '', '', '')
  hi('Identifier', gui08, '', 'none', '')
  hi('Include', gui0D, '', '', '')
  hi('Keyword', gui0E, '', '', '')
  hi('Label', gui0A, '', '', '')
  hi('Number', gui09, '', '', '')
  hi('Operator', gui05, '', 'none', '')
  hi('PreProc', gui0A, '', '', '')
  hi('Repeat', gui0A, '', '', '')
  hi('Special', gui0C, '', '', '')
  hi('SpecialChar', gui0F, '', '', '')
  hi('Statement', gui08, '', '', '')
  hi('StorageClass', gui0A, '', '', '')
  hi('String', gui0B, '', '', '')
  hi('Structure', gui0E, '', '', '')
  hi('Tag', gui0A, '', '', '')
  hi('Todo', gui0A, gui01, '', '')
  hi('Type', gui0A, '', 'none', '')
  hi('Typedef', gui0A, '', '', '')

  -- C highlighting
  hi('cOperator', gui0C, '', '', '')
  hi('cPreCondit', gui0E, '', '', '')

  -- C# highlighting
  hi('csClass', gui0A, '', '', '')
  hi('csAttribute', gui0A, '', '', '')
  hi('csModifier', gui0E, '', '', '')
  hi('csType', gui08, '', '', '')
  hi('csUnspecifiedStatement', gui0D, '', '', '')
  hi('csContextualStatement', gui0E, '', '', '')
  hi('csNewDecleration', gui08, '', '', '')

  -- CSS highlighting
  hi('cssBraces', gui05, '', '', '')
  hi('cssClassName', gui0E, '', '', '')
  hi('cssColor', gui0C, '', '', '')

  -- Diff highlighting
  hi('DiffAdd', gui0B, gui01, '', '')
  hi('DiffChange', gui03, gui01, '', '')
  hi('DiffDelete', gui08, gui01, '', '')
  hi('DiffText', gui0D, gui01, '', '')
  hi('DiffAdded', gui0B, gui00, '', '')
  hi('DiffFile', gui08, gui00, '', '')
  hi('DiffNewFile', gui0B, gui00, '', '')
  hi('DiffLine', gui0D, gui00, '', '')
  hi('DiffRemoved', gui08, gui00, '', '')

  -- Git highlighting
  hi('gitcommitOverflow', gui08, '', '', '')
  hi('gitcommitSummary', gui0B, '', '', '')
  hi('gitcommitComment', gui03, '', '', '')
  hi('gitcommitUntracked', gui03, '', '', '')
  hi('gitcommitDiscarded', gui03, '', '', '')
  hi('gitcommitSelected', gui03, '', '', '')
  hi('gitcommitHeader', gui0E, '', '', '')
  hi('gitcommitSelectedType', gui0D, '', '', '')
  hi('gitcommitUnmergedType', gui0D, '', '', '')
  hi('gitcommitDiscardedType', gui0D, '', '', '')
  hi('gitcommitBranch', gui09, '', 'bold', '')
  hi('gitcommitUntrackedFile', gui0A, '', '', '')
  hi('gitcommitUnmergedFile', gui08, '', 'bold', '')
  hi('gitcommitDiscardedFile', gui08, '', 'bold', '')
  hi('gitcommitSelectedFile', gui0B, '', 'bold', '')

  -- GitGutter highlighting
  hi('GitGutterAdd', gui0B, sign_col_bg, '', '')
  hi('GitGutterChange', gui0D, sign_col_bg, '', '')
  hi('GitGutterDelete', gui08, sign_col_bg, '', '')
  hi('GitGutterChangeDelete', gui0E, sign_col_bg, '', '')

  -- git-signs highlighting
  hi('GitSignsAdd', gui0B, sign_col_bg, '', '')
  hi('GitSignsChange', gui0D, sign_col_bg, '', '')
  hi('GitSignsDelete', gui08, sign_col_bg, '', '')

  -- HTML highlighting
  hi('htmlBold', gui0A, '', '', '')
  hi('htmlItalic', gui0E, '', '', '')
  hi('htmlEndTag', gui05, '', '', '')
  hi('htmlTag', gui05, '', '', '')

  -- JavaScript highlighting
  hi('javaScript', gui05, '', '', '')
  hi('javaScriptBraces', gui05, '', '', '')
  hi('javaScriptNumber', gui09, '', '', '')
  -- pangloss/vim-javascript highlighting
  hi('jsOperator', gui0D, '', '', '')
  hi('jsStatement', gui0E, '', '', '')
  hi('jsReturn', gui0E, '', '', '')
  hi('jsThis', gui08, '', '', '')
  hi('jsClassDefinition', gui0A, '', '', '')
  hi('jsFunction', gui0E, '', '', '')
  hi('jsFuncName', gui0D, '', '', '')
  hi('jsFuncCall', gui0D, '', '', '')
  hi('jsClassFuncName', gui0D, '', '', '')
  hi('jsClassMethodType', gui0E, '', '', '')
  hi('jsRegexpString', gui0C, '', '', '')
  hi('jsGlobalObjects', gui0A, '', '', '')
  hi('jsGlobalNodeObjects', gui0A, '', '', '')
  hi('jsExceptions', gui0A, '', '', '')
  hi('jsBuiltins', gui0A, '', '', '')

  -- Mail highlighting
  hi('mailQuoted1', gui0A, '', '', '')
  hi('mailQuoted2', gui0B, '', '', '')
  hi('mailQuoted3', gui0E, '', '', '')
  hi('mailQuoted4', gui0C, '', '', '')
  hi('mailQuoted5', gui0D, '', '', '')
  hi('mailQuoted6', gui0A, '', '', '')
  hi('mailURL', gui0D, '', '', '')
  hi('mailEmail', gui0D, '', '', '')

  -- Markdown highlighting
  hi('markdownCode', gui0B, '', '', '')
  hi('markdownError', gui05, gui00, '', '')
  hi('markdownCodeBlock', gui0B, '', '', '')
  hi('markdownHeadingDelimiter', gui0D, '', '', '')

  -- NERDTree highlighting
  hi('NERDTreeDirSlash', gui0D, '', '', '')
  hi('NERDTreeExecFile', gui05, '', '', '')

  -- PHP highlighting
  hi('phpMemberSelector', gui05, '', '', '')
  hi('phpComparison', gui05, '', '', '')
  hi('phpParent', gui05, '', '', '')
  hi('phpMethodsVar', gui0C, '', '', '')

  -- Python highlighting
  hi('pythonOperator', gui0E, '', '', '')
  hi('pythonRepeat', gui0E, '', '', '')
  hi('pythonInclude', gui0E, '', '', '')
  hi('pythonStatement', gui0E, '', '', '')

  -- Ruby highlighting
  hi('rubyAttribute', gui0D, '', '', '')
  hi('rubyConstant', gui0A, '', '', '')
  hi('rubyInterpolationDelimiter', gui0F, '', '', '')
  hi('rubyRegexp', gui0C, '', '', '')
  hi('rubySymbol', gui0B, '', '', '')
  hi('rubyStringDelimiter', gui0B, '', '', '')

  -- SASS highlighting
  hi('sassidChar', gui08, '', '', '')
  hi('sassClassChar', gui09, '', '', '')
  hi('sassInclude', gui0E, '', '', '')
  hi('sassMixing', gui0E, '', '', '')
  hi('sassMixinName', gui0D, '', '', '')

  -- Signify highlighting
  hi('SignifySignAdd', gui0B, gui01, '', '')
  hi('SignifySignChange', gui0D, gui01, '', '')
  hi('SignifySignDelete', gui08, gui01, '', '')

  -- Spelling highlighting
  hi('SpellBad', '', '', 'undercurl', gui08)
  hi('SpellLocal', '', '', 'undercurl', gui0C)
  hi('SpellCap', '', '', 'undercurl', gui0D)
  hi('SpellRare', '', '', 'undercurl', gui0E)

  -- Startify highlighting
  hi('StartifyBracket', gui03, '', '', '')
  hi('StartifyFile', gui07, '', '', '')
  hi('StartifyFooter', gui03, '', '', '')
  hi('StartifyHeader', gui0B, '', '', '')
  hi('StartifyNumber', gui09, '', '', '')
  hi('StartifyPath', gui03, '', '', '')
  hi('StartifySection', gui0E, '', '', '')
  hi('StartifySelect', gui0C, '', '', '')
  hi('StartifySlash', gui03, '', '', '')
  hi('StartifySpecial', gui03, '', '', '')

  -- Java highlighting
  hi('javaOperator', gui0D, '', '', '')
end

return M
