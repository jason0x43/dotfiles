local util = require('util')
local g = vim.g

local function hi(group, guifg, guibg, ctermfg, ctermbg, attr, guisp)
  util.hi(
    group, {
      guifg = guifg,
      guibg = guibg,
      ctermfg = ctermfg,
      ctermbg = ctermbg,
      gui = attr,
      cterm = attr,
      guisp = guisp
    }
  )
end

-- Modified from https://github.com/chriskempson/base16-vim
local function apply_theme(theme_name)
  local theme = require('base16.themes')[theme_name]

  -- Terminal color definitions
  local cterm00 = '00'
  local cterm03 = '08'
  local cterm05 = '07'
  local cterm07 = '15'
  local cterm08 = '01'
  local cterm0A = '03'
  local cterm0B = '02'
  local cterm0C = '06'
  local cterm0D = '04'
  local cterm0E = '05'

  local cterm01
  local cterm02
  local cterm04
  local cterm06
  local cterm09
  local cterm0F

  if g.use_256_colorspace then
    cterm01 = '18'
    cterm02 = '19'
    cterm04 = '20'
    cterm06 = '21'
    cterm09 = '16'
    cterm0F = '17'
  else
    cterm01 = '10'
    cterm02 = '11'
    cterm04 = '12'
    cterm06 = '13'
    cterm09 = '09'
    cterm0F = '14'
  end

  g.base16_gui00 = theme.base00
  g.base16_gui01 = theme.base01
  g.base16_gui02 = theme.base02
  g.base16_gui03 = theme.base03
  g.base16_gui04 = theme.base04
  g.base16_gui05 = theme.base05
  g.base16_gui06 = theme.base06
  g.base16_gui07 = theme.base07
  g.base16_gui08 = theme.base08
  g.base16_gui09 = theme.base09
  g.base16_gui0A = theme.base0A
  g.base16_gui0B = theme.base0B
  g.base16_gui0C = theme.base0C
  g.base16_gui0D = theme.base0D
  g.base16_gui0E = theme.base0E
  g.base16_gui0F = theme.base0F

  g.base16_cterm00 = cterm00
  g.base16_cterm01 = cterm01
  g.base16_cterm02 = cterm02
  g.base16_cterm03 = cterm03
  g.base16_cterm04 = cterm04
  g.base16_cterm05 = cterm05
  g.base16_cterm06 = cterm06
  g.base16_cterm07 = cterm07
  g.base16_cterm08 = cterm08
  g.base16_cterm09 = cterm09
  g.base16_cterm0A = cterm0A
  g.base16_cterm0B = cterm0B
  g.base16_cterm0C = cterm0C
  g.base16_cterm0D = cterm0D
  g.base16_cterm0E = cterm0E
  g.base16_cterm0F = cterm0F

  -- standard colors
  local error_fg = theme.base08
  local error_cfg = cterm08
  local info_fg = theme.base0D
  local info_cfg = cterm0D
  local warning_fg = theme.base0A
  local warning_cfg = cterm0A
  local hint_fg = theme.base03
  local hint_cfg = cterm03
  local sign_bg = theme.base01
  local sign_cbg = cterm01

  -- Vim editor colors
  hi('Normal', theme.base05, nil, cterm05, nil, nil, nil)
  hi('NormalFloat', nil, theme.base01, nil, nil, nil, nil)
  hi('Bold', nil, nil, nil, nil, 'bold', nil)
  hi('Debug', theme.base08, nil, cterm08, nil, nil, nil)
  hi('Directory', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('Error', error_fg, nil, error_cfg, nil, nil, nil)
  hi('ErrorMsg', error_fg, theme.base00, error_cfg, cterm00, nil, nil)
  hi('Exception', theme.base08, nil, cterm08, nil, nil, nil)
  hi('FloatBorder', theme.base02, theme.base01, cterm02, cterm01, nil, nil)
  hi('FoldColumn', theme.base0C, theme.base01, cterm0C, cterm01, nil, nil)
  hi('Folded', theme.base03, theme.base01, cterm03, cterm01, nil, nil)
  hi('IncSearch', theme.base00, theme.base0D, cterm00, cterm0D, 'none', nil)
  hi('Italic', nil, nil, nil, nil, 'none', nil)
  hi('Macro', theme.base08, nil, cterm08, nil, nil, nil)
  hi('MatchParen', nil, theme.base01, nil, cterm01, nil, nil)
  hi('MatchParenCur', nil, theme.base01, nil, cterm01, nil, nil)
  hi('ModeMsg', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('MoreMsg', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('Question', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('Search', theme.base00, theme.base0D, cterm00, cterm0D, nil, nil)
  hi('Substitute', theme.base01, theme.base0A, cterm01, cterm0A, 'none', nil)
  hi('SpecialKey', theme.base03, nil, cterm03, nil, nil, nil)
  hi('TooLong', theme.base08, nil, cterm08, nil, nil, nil)
  hi('Underlined', theme.base08, nil, cterm08, nil, nil, nil)
  hi('Visual', theme.base00, theme.base02, cterm00, cterm02, nil, nil)
  hi('VisualNOS', theme.base08, nil, cterm08, nil, nil, nil)
  hi('WarningMsg', theme.base08, nil, cterm08, nil, nil, nil)
  hi('WildMenu', theme.base08, theme.base0A, cterm08, nil, nil, nil)
  hi('Title', theme.base0D, nil, cterm0D, nil, 'none', nil)
  hi('Conceal', theme.base0D, theme.base00, cterm0D, cterm00, nil, nil)
  hi('Cursor', theme.base00, theme.base08, cterm00, cterm05, nil, nil)
  hi('NonText', theme.base03, nil, cterm03, nil, nil, nil)
  hi('LineNr', theme.base03, theme.base01, cterm03, cterm01, nil, nil)
  hi('SignColumn', theme.base03, theme.base01, cterm03, cterm01, nil, nil)
  hi('StatusLine', theme.base04, theme.base02, cterm04, cterm02, 'none', nil)
  hi('StatusLineNC', theme.base03, theme.base01, cterm03, cterm01, 'none', nil)
  hi('VertSplit', theme.base02, theme.base02, cterm02, cterm02, 'none', nil)
  hi('ColorColumn', nil, theme.base01, nil, cterm01, 'none', nil)
  hi('CursorColumn', nil, theme.base01, nil, cterm01, 'none', nil)
  hi('CursorLine', nil, theme.base01, nil, cterm01, 'none', nil)
  hi('CursorLineNr', theme.base04, theme.base01, cterm04, cterm01, nil, nil)
  hi('QuickFixLine', nil, theme.base01, nil, cterm01, 'none', nil)
  hi('PMenu', theme.base05, theme.base01, cterm05, cterm01, 'none', nil)
  hi('PMenuSel', theme.base01, theme.base05, cterm01, cterm05, nil, nil)
  hi('TabLine', theme.base03, theme.base01, cterm03, cterm01, 'none', nil)
  hi('TabLineFill', theme.base03, theme.base01, cterm03, cterm01, 'none', nil)
  hi('TabLineSel', theme.base0B, theme.base01, cterm0B, cterm01, 'none', nil)

  -- Standard syntax highlighting
  hi('Boolean', theme.base09, nil, cterm09, nil, nil, nil)
  hi('Character', theme.base08, nil, cterm08, nil, nil, nil)
  hi('Comment', theme.base03, nil, cterm03, nil, 'italic', nil)
  hi('Conditional', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('Constant', theme.base09, nil, cterm09, nil, nil, nil)
  hi('Define', theme.base0E, nil, cterm0E, nil, 'none', nil)
  hi('Delimiter', theme.base0F, nil, cterm0F, nil, nil, nil)
  hi('Float', theme.base09, nil, cterm09, nil, nil, nil)
  hi('Function', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('Identifier', theme.base08, nil, cterm08, nil, 'none', nil)
  hi('Include', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('Keyword', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('Label', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('Number', theme.base09, nil, cterm09, nil, nil, nil)
  hi('Operator', theme.base05, nil, cterm05, nil, 'none', nil)
  hi('PreProc', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('Repeat', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('Special', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('SpecialChar', theme.base0F, nil, cterm0F, nil, nil, nil)
  hi('Statement', theme.base08, nil, cterm08, nil, nil, nil)
  hi('StorageClass', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('String', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('Structure', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('Tag', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('Todo', theme.base0A, theme.base01, cterm0A, cterm01, nil, nil)
  hi('Type', theme.base0A, nil, cterm0A, nil, 'none', nil)
  hi('Typedef', theme.base0A, nil, cterm0A, nil, nil, nil)

  ---
  -- Extra definitions
  ---

  -- C highlighting
  hi('cOperator', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('cPreCondit', theme.base0E, nil, cterm0E, nil, nil, nil)

  -- C# highlighting
  hi('csClass', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('csAttribute', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('csModifier', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('csType', theme.base08, nil, cterm08, nil, nil, nil)
  hi('csUnspecifiedStatement', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('csContextualStatement', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('csNewDecleration', theme.base08, nil, cterm08, nil, nil, nil)

  -- CSS highlighting
  hi('cssBraces', theme.base05, nil, cterm05, nil, nil, nil)
  hi('cssClassName', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('cssColor', theme.base0C, nil, cterm0C, nil, nil, nil)

  -- Diff highlighting
  hi('DiffAdd', theme.base0B, theme.base01, cterm0B, cterm01, nil, nil)
  hi('DiffChange', theme.base03, theme.base01, cterm03, cterm01, nil, nil)
  hi('DiffDelete', theme.base08, theme.base01, cterm08, cterm01, nil, nil)
  hi('DiffText', theme.base0D, theme.base01, cterm0D, cterm01, nil, nil)
  hi('DiffAdded', theme.base0B, nil, cterm0B, cterm00, nil, nil)
  hi('DiffFile', theme.base08, nil, cterm08, cterm00, nil, nil)
  hi('DiffNewFile', theme.base0B, nil, cterm0B, cterm00, nil, nil)
  hi('DiffLine', theme.base0D, nil, cterm0D, cterm00, nil, nil)
  hi('DiffRemoved', theme.base08, nil, cterm08, cterm00, nil, nil)

  -- Git highlighting
  hi('gitcommitOverflow', theme.base08, nil, cterm08, nil, nil, nil)
  hi('gitcommitSummary', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('gitcommitComment', theme.base03, nil, cterm03, nil, nil, nil)
  hi('gitcommitUntracked', theme.base03, nil, cterm03, nil, nil, nil)
  hi('gitcommitDiscarded', theme.base03, nil, cterm03, nil, nil, nil)
  hi('gitcommitSelected', theme.base03, nil, cterm03, nil, nil, nil)
  hi('gitcommitHeader', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('gitcommitSelectedType', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('gitcommitUnmergedType', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('gitcommitDiscardedType', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('gitcommitBranch', theme.base09, nil, cterm09, nil, 'bold', nil)
  hi('gitcommitUntrackedFile', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('gitcommitUnmergedFile', theme.base08, nil, cterm08, nil, 'bold', nil)
  hi('gitcommitDiscardedFile', theme.base08, nil, cterm08, nil, 'bold', nil)
  hi('gitcommitSelectedFile', theme.base0B, nil, cterm0B, nil, 'bold', nil)

  -- GitGutter highlighting
  hi('GitGutterAdd', theme.base0B, theme.base01, cterm0B, cterm01, nil, nil)
  hi('GitGutterChange', theme.base0D, theme.base01, cterm0D, cterm01, nil, nil)
  hi('GitGutterDelete', theme.base08, theme.base01, cterm08, cterm01, nil, nil)
  hi(
    'GitGutterChangeDelete', theme.base0E, theme.base01, cterm0E, cterm01, nil,
      nil
  )

  -- HTML highlighting
  hi('htmlBold', nil, nil, nil, nil, 'bold', nil)
  hi('htmlItalic', nil, nil, nil, nil, 'italic', nil)
  hi('htmlBoldItalic', nil, nil, nil, nil, 'bold,italic', nil)
  hi('htmlEndTag', theme.base05, nil, cterm05, nil, nil, nil)
  hi('htmlTag', theme.base05, nil, cterm05, nil, nil, nil)

  -- JavaScript highlighting
  hi('javaScript', theme.base05, nil, cterm05, nil, nil, nil)
  hi('javaScriptBraces', theme.base05, nil, cterm05, nil, nil, nil)
  hi('javaScriptNumber', theme.base09, nil, cterm09, nil, nil, nil)
  -- pangloss/vim-javascript highlighting
  hi('jsOperator', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('jsStatement', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('jsReturn', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('jsThis', theme.base08, nil, cterm08, nil, nil, nil)
  hi('jsClassDefinition', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('jsFunction', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('jsFuncName', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('jsFuncCall', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('jsClassFuncName', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('jsClassMethodType', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('jsRegexpString', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('jsGlobalObjects', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('jsGlobalNodeObjects', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('jsExceptions', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('jsBuiltins', theme.base0A, nil, cterm0A, nil, nil, nil)

  -- Mail highlighting
  hi('mailQuoted1', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('mailQuoted2', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('mailQuoted3', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('mailQuoted4', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('mailQuoted5', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('mailQuoted6', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('mailURL', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('mailEmail', theme.base0D, nil, cterm0D, nil, nil, nil)

  -- Markdown highlighting
  hi('markdownCode', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('markdownError', error_fg, theme.base00, cterm05, cterm00, nil, nil)
  hi('markdownCodeBlock', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('markdownHeadingDelimiter', theme.base0D, nil, cterm0D, nil, nil, nil)

  -- NERDTree highlighting
  hi('NERDTreeDirSlash', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('NERDTreeExecFile', theme.base05, nil, cterm05, nil, nil, nil)

  -- PHP highlighting
  hi('phpMemberSelector', theme.base05, nil, cterm05, nil, nil, nil)
  hi('phpComparison', theme.base05, nil, cterm05, nil, nil, nil)
  hi('phpParent', theme.base05, nil, cterm05, nil, nil, nil)
  hi('phpMethodsVar', theme.base0C, nil, cterm0C, nil, nil, nil)

  -- Python highlighting
  hi('pythonOperator', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('pythonRepeat', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('pythonInclude', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('pythonStatement', theme.base0E, nil, cterm0E, nil, nil, nil)

  -- Ruby highlighting
  hi('rubyAttribute', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('rubyConstant', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('rubyInterpolationDelimiter', theme.base0F, nil, cterm0F, nil, nil, nil)
  hi('rubyRegexp', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('rubySymbol', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('rubyStringDelimiter', theme.base0B, nil, cterm0B, nil, nil, nil)

  -- SASS highlighting
  hi('sassidChar', theme.base08, nil, cterm08, nil, nil, nil)
  hi('sassClassChar', theme.base09, nil, cterm09, nil, nil, nil)
  hi('sassInclude', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('sassMixing', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('sassMixinName', theme.base0D, nil, cterm0D, nil, nil, nil)

  -- Signify highlighting
  hi('SignifySignAdd', theme.base0B, theme.base01, cterm0B, cterm01, nil, nil)
  hi('SignifySignChange', theme.base0D, theme.base01, cterm0D, cterm01, nil, nil)
  hi('SignifySignDelete', theme.base08, theme.base01, cterm08, cterm01, nil, nil)

  -- Spelling highlighting
  hi('SpellBad', nil, nil, nil, nil, 'undercurl', theme.base08)
  hi('SpellLocal', nil, nil, nil, nil, 'undercurl', theme.base0C)
  hi('SpellCap', nil, nil, nil, nil, 'undercurl', theme.base0D)
  hi('SpellRare', nil, nil, nil, nil, 'undercurl', theme.base0E)

  -- Startify highlighting
  hi('StartifyBracket', theme.base03, nil, cterm03, nil, nil, nil)
  hi('StartifyFile', theme.base07, nil, cterm07, nil, nil, nil)
  hi('StartifyFooter', theme.base03, nil, cterm03, nil, nil, nil)
  hi('StartifyHeader', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('StartifyNumber', theme.base09, nil, cterm09, nil, nil, nil)
  hi('StartifyPath', theme.base03, nil, cterm03, nil, nil, nil)
  hi('StartifySection', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('StartifySelect', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('StartifySlash', theme.base03, nil, cterm03, nil, nil, nil)
  hi('StartifySpecial', theme.base03, nil, cterm03, nil, nil, nil)

  -- Java highlighting
  hi('javaOperator', theme.base0D, nil, cterm0D, nil, nil, nil)

  -- Treesitter
  hi('TSNone', theme.base05, theme.base00, cterm05, cterm00, nil, nil)
  hi('TSPunctDelimiter', theme.base07, nil, cterm07, nil, nil, nil)
  hi('TSPunctBracket', theme.base07, nil, cterm07, nil, nil, nil)
  hi('TSPunctSpecial', theme.base0F, nil, cterm0F, nil, nil, nil)
  hi('TSConstant', theme.base09, nil, cterm0B, nil, 'bold', nil)
  hi('TSConstBuiltin', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('TSConstMacro', theme.base0E, nil, cterm0E, nil, 'none', nil)
  hi('TSString', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('TSStringRegex', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('TSStringEscape', theme.base0F, nil, cterm0F, nil, nil, nil)
  hi('TSCharacter', theme.base08, nil, cterm08, nil, nil, nil)
  hi('TSNumber', theme.bae0B, nil, cterm0B, nil, nil, nil)
  hi('TSBoolean', theme.base0B, nil, cterm0B, nil, 'bold', nil)
  hi('TSFloat', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('TSFunction', theme.base0D, nil, cterm0D, nil, 'bold', nil)
  hi('TSFuncBuiltin', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('TSFuncMacro', theme.base08, nil, cterm08, nil, nil, nil)
  hi('TSParameter', theme.base08, nil, cterm08, nil, 'none', nil)
  hi('TSParameterReference', theme.base08, nil, cterm08, nil, 'none', nil)
  hi('TSMethod', theme.base0D, nil, cterm0D, nil, 'bold', nil)
  hi('TSField', theme.base0A, nil, cterm0A, nil, 'none', nil)
  hi('TSProperty', theme.base08, nil, cterm08, nil, 'none', nil)
  hi('TSConstructor', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('TSAnnotation', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('TSAttribute', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('TSNamespace', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('TSConditional', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('TSRepeat', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('TSLabel', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('TSOperator', theme.base07, nil, cterm07, nil, 'none', nil)
  hi('TSKeyword', theme.base0E, nil, cterm0E, nil, nil, nil)
  hi('TSKeywordFunction', theme.base0E, nil, cterm0E, nil, 'bold', nil)
  hi('TSKeywordOperator', theme.base05, nil, cterm05, nil, 'none', nil)
  hi('TSException', theme.base08, nil, cterm08, nil, nil, nil)
  hi('TSType', theme.base0A, nil, cterm0A, nil, 'bold', nil)
  hi('TSTypeBuiltin', theme.base0A, nil, cterm0A, nil, 'bold', nil)
  hi('TSInclude', theme.base0D, nil, cterm0D, nil, nil, nil)
  hi('TSVariableBuiltin', theme.base0C, nil, cterm0C, nil, nil, nil)
  hi('TSText', theme.base05, theme.base00, cterm05, cterm00, nil, nil)
  hi('TSStrong', theme.base07, theme.base00, cterm07, cterm00, 'bold', nil)
  hi('TSEmphasis', theme.base06, theme.base00, cterm06, cterm00, 'italic', nil)
  hi(
    'TSUnderline', theme.base05, theme.base00, cterm05, cterm00, 'underline',
      nil
  )
  hi('TSTitle', theme.base0D, nil, cterm0D, nil, 'none', nil)
  hi('TSLiteral', theme.base0B, nil, cterm0B, nil, nil, nil)
  hi('TSURI', theme.base08, nil, cterm08, nil, nil, nil)
  hi('TSTag', theme.base0A, nil, cterm0A, nil, nil, nil)
  hi('TSTagDelimiter', theme.base0F, nil, cterm0F, nil, nil, nil)
  hi('TSDefinitionUsage', nil, theme.base02, nil, cterm02, nil, nil)
  hi('TSDefinition', theme.base01, theme.base0A, cterm01, cterm0A, nil, nil)
  hi('TSCurrentScope', nil, theme.base01, nil, cterm01, 'none', nil)

  -- LSP
  hi('LspDiagnosticsDefaultError', error_fg, nil, error_cfg, nil, nil, nil)
  hi(
    'LspDiagnosticsSignError', error_fg, sign_bg, error_cfg, sign_cbg, 'bold',
      nil
  )
  hi('LspDiagnosticsDefaultHint', hint_fg, nil, hint_cfg, nil, nil, nil)
  hi('LspDiagnosticsSignHint', hint_fg, sign_bg, hint_cfg, sign_cbg, 'bold', nil)
  hi('LspDiagnosticsDefaultInformation', info_fg, nil, info_cfg, nil, nil, nil)
  hi(
    'LspDiagnosticsSignInformation', info_fg, sign_bg, info_cfg, sign_cbg,
      'bold', nil
  )
  hi('LspDiagnosticsDefaultWarning', warning_fg, nil, warning_cfg, nil, nil, nil)
  hi(
    'LspDiagnosticsSignWarning', warning_fg, sign_bg, warning_cfg, sign_cbg,
      'bold', nil
  )
  hi('LspDiagnosticsUnderlineError', nil, nil, nil, nil, 'undercurl', error_fg)

  -- status line extra
  hi('StatusLineOuter', theme.base00, theme.base05, cterm00, cterm05, nil, nil)
  hi('StatusLineMiddle', theme.base00, theme.base02, cterm00, cterm02, nil, nil)
  hi('StatusLineInner', theme.base05, theme.base01, cterm06, cterm01, nil, nil)
  hi('StatusLineFileInfo', theme.base05, theme.base01, cterm06, cterm01, 'bold', nil)
  hi('StatusLineInnerSep', theme.base02, theme.base01, cterm02, cterm01, nil, nil)
  hi(
    'StatusLineLspDiagnosticsError', error_fg, theme.base01, error_cfg, cterm01,
      nil, nil
  )
  hi(
    'StatusLineLspDiagnosticsWarning', warning_fg, theme.base01, warning_cfg,
      cterm01, nil, nil
  )
  hi(
    'StatusLineLspDiagnosticsHint', hint_fg, theme.base01, hint_cfg, cterm01,
      nil, nil
  )
  hi('StatusLineTreeSitter', theme.base0B, theme.base01, cterm0B, cterm01, nil, nil)
end

return { apply_theme = apply_theme }
