local M = {}
local module = ...
local hi = require('util.theme').hi

-- Modified from https://github.com/chriskempson/base16-vim
function M.apply_theme(theme_name)
  if type(theme_name) ~= 'string' then
    print('Missing or invalid theme name: ' .. vim.inspect(theme_name))
    return
  end

  vim.g.colors_name = 'base16'
  if theme_name:find('light') ~= nil then
    vim.go.background = 'light'
  else
    vim.go.background = 'dark'
  end

  local shift = require('util.theme').shift
  local theme = require(module .. '.themes')[theme_name]
  local colors = {}

  colors.gui00 = theme.base00
  colors.gui01 = theme.base01
  colors.gui02 = theme.base02
  colors.gui03 = theme.base03
  colors.gui04 = theme.base04
  colors.gui05 = theme.base05
  colors.gui06 = theme.base06
  colors.gui07 = theme.base07
  colors.gui08 = theme.base08
  colors.gui09 = theme.base09
  colors.gui0A = theme.base0A
  colors.gui0B = theme.base0B
  colors.gui0C = theme.base0C
  colors.gui0D = theme.base0D
  colors.gui0E = theme.base0E
  colors.gui0F = theme.base0F

  colors.error_fg = theme.base08
  colors.error_cfg = colors.cterm08
  colors.info_fg = theme.base0D
  colors.info_cfg = colors.cterm0D
  colors.warning_fg = theme.base0A
  colors.warning_cfg = colors.cterm0A
  colors.hint_fg = theme.base03
  colors.hint_cfg = colors.cterm03
  colors.sign_bg = theme.base01
  colors.sign_cbg = colors.cterm01

  -- standard colors
  -- Vim editor colors
  hi('Normal', colors.gui05, nil, nil, nil)
  hi('NormalFloat', nil, colors.gui01, nil, nil)
  hi('Bold', nil, nil, 'bold', nil)
  hi('Debug', colors.gui08, nil, nil, nil)
  hi('Directory', colors.gui0D, nil, nil, nil)
  hi('Error', colors.error_fg, '', nil, nil)
  hi('ErrorMsg', colors.error_fg, colors.gui00, nil, nil)
  hi('Exception', colors.gui08, nil, nil, nil)
  hi('FloatBorder', colors.gui02, colors.gui01, nil, nil)
  hi('FoldColumn', colors.gui0C, colors.gui01, nil, nil)
  hi('Folded', colors.gui03, colors.gui01, nil, nil)
  hi('IncSearch', colors.gui00, colors.gui0D, 'none', nil)
  hi('Italic', nil, nil, 'none', nil)
  hi('Macro', colors.gui08, nil, nil, nil)
  hi('MatchParen', nil, colors.gui01, nil, nil)
  hi('MatchParenCur', nil, colors.gui01, nil, nil)
  hi('ModeMsg', colors.gui0B, nil, nil, nil)
  hi('MoreMsg', colors.gui0B, nil, nil, nil)
  hi('Question', colors.gui0D, nil, nil, nil)
  hi('Search', colors.gui00, colors.gui0D, nil, nil)
  hi('Substitute', colors.gui01, colors.gui0A, 'none', nil)
  hi('SpecialKey', colors.gui03, nil, nil, nil)
  hi('TooLong', colors.gui08, nil, nil, nil)
  hi('Underlined', colors.gui08, nil, nil, nil)
  hi('Visual', nil, shift(colors.gui0E, 0.7), nil, nil)
  hi('VisualNOS', colors.gui08, nil, nil, nil)
  hi('WarningMsg', colors.gui08, nil, nil, nil)
  hi('WildMenu', colors.gui08, colors.gui0A, nil, nil)
  hi('Title', colors.gui0D, nil, 'none', nil)
  hi('Conceal', colors.gui0D, colors.gui00, nil, nil)
  hi('Cursor', colors.gui00, colors.gui08, nil, nil)
  hi('NonText', colors.gui03, nil, nil, nil)
  hi('LineNr', colors.gui03, colors.gui01, nil, nil)
  hi('SignColumn', colors.gui03, colors.gui01, nil, nil)
  hi('StatusLine', colors.gui04, colors.gui02, 'none', nil)
  hi('StatusLineNC', colors.gui03, colors.gui01, 'none', nil)
  hi('VertSplit', colors.gui02, colors.gui02, 'none', nil)
  hi('ColorColumn', nil, colors.gui01, 'none', nil)
  hi('CursorColumn', nil, colors.gui01, 'none', nil)
  hi('CursorLine', nil, colors.gui01, 'none', nil)
  hi('CursorLineNr', colors.gui04, colors.gui01, nil, nil)
  hi('QuickFixLine', nil, colors.gui01, 'none', nil)
  hi('PMenu', colors.gui05, colors.gui01, 'none', nil)
  hi('PMenuSel', colors.gui01, colors.gui05, nil, nil)
  hi('TabLine', colors.gui03, colors.gui01, 'none', nil)
  hi('TabLineFill', colors.gui03, colors.gui01, 'none', nil)
  hi('TabLineSel', colors.gui0B, colors.gui01, 'none', nil)

  -- Standard syntax highlighting
  hi('Boolean', colors.gui09, nil, nil, nil)
  hi('Character', colors.gui08, nil, nil, nil)
  hi('Comment', colors.gui03, nil, 'italic', nil)
  hi('Conditional', colors.gui0E, nil, nil, nil)
  hi('Constant', colors.gui09, nil, nil, nil)
  hi('Define', colors.gui0E, nil, 'none', nil)
  hi('Delimiter', colors.gui0F, nil, nil, nil)
  hi('Float', colors.gui09, nil, nil, nil)
  hi('Function', colors.gui0D, nil, nil, nil)
  hi('Identifier', colors.gui08, nil, 'none', nil)
  hi('Include', colors.gui0D, nil, nil, nil)
  hi('Keyword', colors.gui0E, nil, nil, nil)
  hi('Label', colors.gui0A, nil, nil, nil)
  hi('Number', colors.gui09, nil, nil, nil)
  hi('Operator', colors.gui05, nil, 'none', nil)
  hi('PreProc', colors.gui0A, nil, nil, nil)
  hi('Repeat', colors.gui0A, nil, nil, nil)
  hi('Special', colors.gui0C, nil, nil, nil)
  hi('SpecialChar', colors.gui0F, nil, nil, nil)
  hi('Statement', colors.gui08, nil, nil, nil)
  hi('StorageClass', colors.gui0A, nil, nil, nil)
  hi('String', colors.gui0B, nil, nil, nil)
  hi('Structure', colors.gui0E, nil, nil, nil)
  hi('Tag', colors.gui0A, nil, nil, nil)
  hi('Todo', colors.gui0A, colors.gui01, nil, nil)
  hi('Type', colors.gui0A, nil, 'none', nil)
  hi('Typedef', colors.gui0A, nil, nil, nil)

  ---
  -- Extra definitions
  ---

  -- C highlighting
  hi('cOperator', colors.gui0C, nil, nil, nil)
  hi('cPreCondit', colors.gui0E, nil, nil, nil)

  -- C# highlighting
  hi('csClass', colors.gui0A, nil, nil, nil)
  hi('csAttribute', colors.gui0A, nil, nil, nil)
  hi('csModifier', colors.gui0E, nil, nil, nil)
  hi('csType', colors.gui08, nil, nil, nil)
  hi('csUnspecifiedStatement', colors.gui0D, nil, nil, nil)
  hi('csContextualStatement', colors.gui0E, nil, nil, nil)
  hi('csNewDecleration', colors.gui08, nil, nil, nil)

  -- CSS highlighting
  hi('cssBraces', colors.gui05, nil, nil, nil)
  hi('cssClassName', colors.gui0E, nil, nil, nil)
  hi('cssColor', colors.gui0C, nil, nil, nil)

  -- Diff highlighting
  hi('DiffAdd', colors.gui0B, shift(colors.gui0B, 0.88), nil, nil)
  hi('DiffChange', colors.gui03, shift(colors.gui03, 0.88), nil, nil)
  hi('DiffDelete', colors.gui08, shift(colors.gui08, 0.88), nil, nil)
  hi('DiffText', colors.gui0D, colors.gui01, nil, nil)
  hi('DiffAdded', colors.gui0B, nil, nil, nil)
  hi('DiffFile', colors.gui08, nil, nil, nil)
  hi('DiffNewFile', colors.gui0B, nil, nil, nil)
  hi('DiffLine', colors.gui0D, nil, nil, nil)
  hi('DiffRemoved', colors.gui08, nil, nil, nil)

  -- Git highlighting
  hi('gitcommitOverflow', colors.gui08, nil, nil, nil)
  hi('gitcommitSummary', colors.gui0B, nil, nil, nil)
  hi('gitcommitComment', colors.gui03, nil, nil, nil)
  hi('gitcommitUntracked', colors.gui03, nil, nil, nil)
  hi('gitcommitDiscarded', colors.gui03, nil, nil, nil)
  hi('gitcommitSelected', colors.gui03, nil, nil, nil)
  hi('gitcommitHeader', colors.gui0E, nil, nil, nil)
  hi('gitcommitSelectedType', colors.gui0D, nil, nil, nil)
  hi('gitcommitUnmergedType', colors.gui0D, nil, nil, nil)
  hi('gitcommitDiscardedType', colors.gui0D, nil, nil, nil)
  hi('gitcommitBranch', colors.gui09, nil, 'bold', nil)
  hi('gitcommitUntrackedFile', colors.gui0A, nil, nil, nil)
  hi('gitcommitUnmergedFile', colors.gui08, nil, 'bold', nil)
  hi('gitcommitDiscardedFile', colors.gui08, nil, 'bold', nil)
  hi('gitcommitSelectedFile', colors.gui0B, nil, 'bold', nil)

  -- GitGutter highlighting
  hi('GitGutterAdd', colors.gui0B, colors.gui01, nil, nil)
  hi('GitGutterChange', colors.gui0D, colors.gui01, nil, nil)
  hi('GitGutterDelete', colors.gui08, colors.gui01, nil, nil)
  hi('GitGutterChangeDelete', colors.gui0E, colors.gui01, nil, nil)

  -- HTML highlighting
  hi('htmlBold', nil, nil, 'bold', nil)
  hi('htmlItalic', nil, nil, 'italic', nil)
  hi('htmlBoldItalic', nil, nil, 'bold,italic', nil)
  hi('htmlEndTag', colors.gui05, nil, nil, nil)
  hi('htmlTag', colors.gui05, nil, nil, nil)

  -- JavaScript highlighting
  hi('javaScript', colors.gui05, nil, nil, nil)
  hi('javaScriptBraces', colors.gui05, nil, nil, nil)
  hi('javaScriptNumber', colors.gui09, nil, nil, nil)
  -- pangloss/vim-javascript highlighting
  hi('jsOperator', colors.gui0D, nil, nil, nil)
  hi('jsStatement', colors.gui0E, nil, nil, nil)
  hi('jsReturn', colors.gui0E, nil, nil, nil)
  hi('jsThis', colors.gui08, nil, nil, nil)
  hi('jsClassDefinition', colors.gui0A, nil, nil, nil)
  hi('jsFunction', colors.gui0E, nil, nil, nil)
  hi('jsFuncName', colors.gui0D, nil, nil, nil)
  hi('jsFuncCall', colors.gui0D, nil, nil, nil)
  hi('jsClassFuncName', colors.gui0D, nil, nil, nil)
  hi('jsClassMethodType', colors.gui0E, nil, nil, nil)
  hi('jsRegexpString', colors.gui0C, nil, nil, nil)
  hi('jsGlobalObjects', colors.gui0A, nil, nil, nil)
  hi('jsGlobalNodeObjects', colors.gui0A, nil, nil, nil)
  hi('jsExceptions', colors.gui0A, nil, nil, nil)
  hi('jsBuiltins', colors.gui0A, nil, nil, nil)

  -- Mail highlighting
  hi('mailQuoted1', colors.gui0A, nil, nil, nil)
  hi('mailQuoted2', colors.gui0B, nil, nil, nil)
  hi('mailQuoted3', colors.gui0E, nil, nil, nil)
  hi('mailQuoted4', colors.gui0C, nil, nil, nil)
  hi('mailQuoted5', colors.gui0D, nil, nil, nil)
  hi('mailQuoted6', colors.gui0A, nil, nil, nil)
  hi('mailURL', colors.gui0D, nil, nil, nil)
  hi('mailEmail', colors.gui0D, nil, nil, nil)

  -- Markdown highlighting
  hi('markdownCode', colors.gui0B, nil, nil, nil)
  hi('markdownError', colors.error_fg, colors.gui00, nil, nil)
  hi('markdownCodeBlock', colors.gui0B, nil, nil, nil)
  hi('markdownHeadingDelimiter', colors.gui0D, nil, nil, nil)

  -- NERDTree highlighting
  hi('NERDTreeDirSlash', colors.gui0D, nil, nil, nil)
  hi('NERDTreeExecFile', colors.gui05, nil, nil, nil)

  -- PHP highlighting
  hi('phpMemberSelector', colors.gui05, nil, nil, nil)
  hi('phpComparison', colors.gui05, nil, nil, nil)
  hi('phpParent', colors.gui05, nil, nil, nil)
  hi('phpMethodsVar', colors.gui0C, nil, nil, nil)

  -- Python highlighting
  hi('pythonOperator', colors.gui0E, nil, nil, nil)
  hi('pythonRepeat', colors.gui0E, nil, nil, nil)
  hi('pythonInclude', colors.gui0E, nil, nil, nil)
  hi('pythonStatement', colors.gui0E, nil, nil, nil)

  -- Ruby highlighting
  hi('rubyAttribute', colors.gui0D, nil, nil, nil)
  hi('rubyConstant', colors.gui0A, nil, nil, nil)
  hi('rubyInterpolationDelimiter', colors.gui0F, nil, nil, nil)
  hi('rubyRegexp', colors.gui0C, nil, nil, nil)
  hi('rubySymbol', colors.gui0B, nil, nil, nil)
  hi('rubyStringDelimiter', colors.gui0B, nil, nil, nil)

  -- SASS highlighting
  hi('sassidChar', colors.gui08, nil, nil, nil)
  hi('sassClassChar', colors.gui09, nil, nil, nil)
  hi('sassInclude', colors.gui0E, nil, nil, nil)
  hi('sassMixing', colors.gui0E, nil, nil, nil)
  hi('sassMixinName', colors.gui0D, nil, nil, nil)

  -- Signify highlighting
  hi('SignifySignAdd', colors.gui0B, colors.gui01, nil, nil)
  hi('SignifySignChange', colors.gui0D, colors.gui01, nil, nil)
  hi('SignifySignDelete', colors.gui08, colors.gui01, nil, nil)

  -- Spelling highlighting
  hi('SpellBad', nil, nil, 'undercurl', colors.gui08)
  hi('SpellLocal', nil, nil, 'undercurl', colors.gui0C)
  hi('SpellCap', nil, nil, 'undercurl', colors.gui0D)
  hi('SpellRare', nil, nil, 'undercurl', colors.gui0E)

  -- Startify highlighting
  hi('StartifyBracket', colors.gui03, nil, nil, nil)
  hi('StartifyFile', colors.gui07, nil, nil, nil)
  hi('StartifyFooter', colors.gui03, nil, nil, nil)
  hi('StartifyHeader', colors.gui0B, nil, nil, nil)
  hi('StartifyNumber', colors.gui09, nil, nil, nil)
  hi('StartifyPath', colors.gui03, nil, nil, nil)
  hi('StartifySection', colors.gui0E, nil, nil, nil)
  hi('StartifySelect', colors.gui0C, nil, nil, nil)
  hi('StartifySlash', colors.gui03, nil, nil, nil)
  hi('StartifySpecial', colors.gui03, nil, nil, nil)

  -- Java highlighting
  hi('javaOperator', colors.gui0D, nil, nil, nil)

  -- Treesitter
  hi('TSNone', colors.gui05, colors.gui00, nil, nil)
  hi('TSPunctDelimiter', colors.gui07, nil, nil, nil)
  hi('TSPunctBracket', colors.gui07, nil, nil, nil)
  hi('TSPunctSpecial', colors.gui0F, nil, nil, nil)
  hi('TSConstant', colors.gui09, nil, 'bold', nil)
  hi('TSConstBuiltin', colors.gui0C, nil, nil, nil)
  hi('TSConstMacro', colors.gui0E, nil, 'none', nil)
  hi('TSString', colors.gui0B, nil, nil, nil)
  hi('TSStringRegex', colors.gui0B, nil, nil, nil)
  hi('TSStringEscape', colors.gui0F, nil, nil, nil)
  hi('TSCharacter', colors.gui08, nil, nil, nil)
  hi('TSNumber', colors.gui0B, nil, nil, nil)
  hi('TSBoolean', colors.gui0B, nil, 'bold', nil)
  hi('TSFloat', colors.gui0B, nil, nil, nil)
  hi('TSFunction', colors.gui0D, nil, 'bold', nil)
  hi('TSFuncBuiltin', colors.gui0C, nil, nil, nil)
  hi('TSFuncMacro', colors.gui08, nil, nil, nil)
  hi('TSParameter', colors.gui08, nil, 'none', nil)
  hi('TSParameterReference', colors.gui08, nil, 'none', nil)
  hi('TSMethod', colors.gui0D, nil, 'bold', nil)
  hi('TSField', colors.gui0A, nil, 'none', nil)
  hi('TSProperty', colors.gui08, nil, 'none', nil)
  hi('TSConstructor', colors.gui0C, nil, nil, nil)
  hi('TSAnnotation', colors.gui0A, nil, nil, nil)
  hi('TSAttribute', colors.gui0A, nil, nil, nil)
  hi('TSNamespace', colors.gui0D, nil, nil, nil)
  hi('TSConditional', colors.gui0E, nil, nil, nil)
  hi('TSRepeat', colors.gui0A, nil, nil, nil)
  hi('TSLabel', colors.gui0A, nil, nil, nil)
  hi('TSOperator', colors.gui07, nil, 'none', nil)
  hi('TSKeyword', colors.gui0E, nil, nil, nil)
  hi('TSKeywordFunction', colors.gui0E, nil, 'bold', nil)
  hi('TSKeywordOperator', colors.gui05, nil, 'none', nil)
  hi('TSException', colors.gui08, nil, nil, nil)
  hi('TSType', colors.gui0A, nil, 'bold', nil)
  hi('TSTypeBuiltin', colors.gui0A, nil, 'bold', nil)
  hi('TSInclude', colors.gui0D, nil, nil, nil)
  hi('TSVariableBuiltin', colors.gui0C, nil, nil, nil)
  hi('TSText', colors.gui05, colors.gui00, nil, nil)
  hi('TSStrong', colors.gui07, colors.gui00, 'bold', nil)
  hi('TSEmphasis', colors.gui06, colors.gui00, 'italic', nil)
  hi('TSUnderline', colors.gui05, colors.gui00, 'underline', nil)
  hi('TSTitle', colors.gui0D, nil, 'none', nil)
  hi('TSLiteral', colors.gui0B, nil, nil, nil)
  hi('TSURI', colors.gui08, nil, nil, nil)
  hi('TSTag', colors.gui0A, nil, nil, nil)
  hi('TSTagDelimiter', colors.gui0F, nil, nil, nil)
  hi('TSDefinitionUsage', nil, colors.gui02, nil, nil)
  hi('TSDefinition', colors.gui01, colors.gui0A, nil, nil)
  hi('TSCurrentScope', nil, colors.gui01, 'none', nil)

  -- LSP
  hi('LspDiagnosticsDefaultError', colors.error_fg, nil, nil, nil)
  hi('LspDiagnosticsSignError', colors.error_fg, colors.sign_bg, 'bold', nil)
  hi('LspDiagnosticsDefaultHint', colors.hint_fg, nil, nil, nil)
  hi('LspDiagnosticsSignHint', colors.hint_fg, colors.sign_bg, 'bold', nil)
  hi('LspDiagnosticsDefaultInformation', colors.info_fg, nil, nil, nil)
  hi(
    'LspDiagnosticsSignInformation',
    colors.info_fg,
    colors.sign_bg,
    'bold',
    nil
  )
  hi('LspDiagnosticsDefaultWarning', colors.warning_fg, nil, nil, nil)
  hi(
    'LspDiagnosticsSignWarning',
    colors.warning_fg,
    colors.sign_bg,
    'bold',
    nil
  )
  hi('LspDiagnosticsUnderlineError', nil, nil, 'undercurl', colors.error_fg)

  -- status line extra (for galaxyline)
  hi('StatusLineOuter', colors.gui00, colors.gui05, nil, nil)
  hi('StatusLineMiddle', colors.gui00, colors.gui02, nil, nil)
  hi('StatusLineInner', colors.gui05, colors.gui01, nil, nil)
  hi('StatusLineFileInfo', colors.gui05, colors.gui01, 'bold', nil)
  hi('StatusLineInnerSep', colors.gui02, colors.gui01, nil, nil)
  hi('StatusLineLspDiagnosticsError', colors.error_fg, colors.gui01, nil, nil)
  hi(
    'StatusLineLspDiagnosticsWarning',
    colors.warning_fg,
    colors.gui01,
    nil,
    nil
  )
  hi('StatusLineLspDiagnosticsHint', colors.hint_fg, colors.gui01, nil, nil)
  hi('StatusLineTreeSitter', colors.gui0B, colors.gui01, nil, nil)

  -- trouble
  hi('TroubleCount', colors.gui0B, nil, 'none', nil)
  hi('TroubleSignError', colors.error_fg, nil, 'none', nil)
  hi('TroubleSignWarning', colors.warning_fg, nil, 'none', nil)
  hi('TroubleSignInformation', colors.info_fg, nil, 'none', nil)
  hi('TroubleSignHint', colors.hint_fg, nil, 'none', nil)
  hi('TroubleSignOther', colors.gui02, nil, 'none', nil)
  hi('TroubleFoldIcon', colors.gui02, nil, 'none', nil)
  hi('TroubleIndent', colors.gui02, nil, 'none', nil)
  hi('TroubleLocation', colors.gui02, nil, 'none', nil)

  -- Neogit
  hi('NeogitHunkHeader', colors.gui0D, colors.gui01, 'none', nil)
  hi('NeogitFold', nil, colors.gui01, 'none', nil)

  -- Indent-blankline
  hi('IndentBlanklineChar', shift(colors.gui01, -0.15), nil, 'none', nil)

  -- Diagnostics
  hi('DiagnosticHint', colors.hint_fg, nil, 'none', nil)
  hi('DiagnosticSignHint', colors.hint_fg, colors.sign_bg, 'none', nil)
end

return M
