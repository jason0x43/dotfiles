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

  local hi = vim.api.nvim_set_hl

  hi(0, 'Normal', { fg = gui05, bg = gui00 })
  hi(0, 'Bold', { bold = true })
  hi(0, 'Debug', { fg = gui08 })
  hi(0, 'Directory', { fg = gui0D })
  hi(0, 'Error', { fg = gui00, bg = gui08 })
  hi(0, 'ErrorMsg', { fg = gui08, bg = gui00 })
  hi(0, 'Exception', { fg = gui08 })
  hi(0, 'FoldColumn', { fg = gui0C, bg = gui01 })
  hi(0, 'Folded', { fg = gui03, bg = gui01 })
  hi(0, 'IncSearch', { fg = gui01, bg = gui09 })
  hi(0, 'Italic', { italic = true })
  hi(0, 'Macro', { fg = gui08 })
  hi(0, 'MatchParen', { bg = gui03 })
  hi(0, 'ModeMsg', { fg = gui0B })
  hi(0, 'MoreMsg', { fg = gui0B })
  hi(0, 'Question', { fg = gui0D })
  hi(0, 'Search', { fg = gui01, bg = gui0A })
  hi(0, 'Substitute', { fg = gui01, bg = gui0A })
  hi(0, 'SpecialKey', { fg = gui03 })
  hi(0, 'TooLong', { fg = gui08 })
  hi(0, 'Underlined', { fg = gui08 })
  hi(0, 'Visual', { fg = gui02 })
  hi(0, 'VisualNOS', { fg = gui08 })
  hi(0, 'WarningMsg', { fg = gui08 })
  hi(0, 'WildMenu', { fg = gui08, bg = gui0A })
  hi(0, 'Title', { fg = gui0D })
  hi(0, 'Conceal', { fg = gui0D, bg = gui00 })
  hi(0, 'Cursor', { fg = gui00, bg = gui05 })
  hi(0, 'NonText', { fg = gui03 })
  hi(0, 'LineNr', { fg = gui03, bg = sign_col_bg })
  hi(0, 'SignColumn', { fg = gui03, bg = sign_col_bg })
  hi(0, 'StatusLine', { fg = gui04, bg = gui02 })
  hi(0, 'StatusLineNC', { fg = gui03, bg = gui01 })
  hi(0, 'VertSplit', { fg = gui02, bg = gui02 })
  hi(0, 'ColorColumn', { bg = gui01 })
  hi(0, 'CursorColumn', { bg = gui01 })
  hi(0, 'CursorLine', { bg = gui01 })
  hi(0, 'CursorLineNr', { fg = gui04, bg = sign_col_bg })
  hi(0, 'QuickFixLine', { bg = gui01 })
  hi(0, 'PMenu', { fg = gui05, bg = gui01 })
  hi(0, 'PMenuSel', { fg = gui01, bg = gui05 })
  hi(0, 'TabLine', { fg = gui03, bg = gui01 })
  hi(0, 'TabLineFill', { fg = gui03, bg = gui01 })
  hi(0, 'TabLineSel', { fg = gui0B, bg = gui01 })

  -- Standard syntax highlighting
  hi(0, 'Boolean', { fg = gui09 })
  hi(0, 'Character', { fg = gui08 })
  hi(0, 'Comment', { fg = gui03 })
  hi(0, 'Conditional', { fg = gui0E })
  hi(0, 'Constant', { fg = gui09 })
  hi(0, 'Define', { fg = gui0E })
  hi(0, 'Delimiter', { fg = gui0F })
  hi(0, 'Float', { fg = gui09 })
  hi(0, 'Function', { fg = gui0D })
  hi(0, 'Identifier', { fg = gui08 })
  hi(0, 'Include', { fg = gui0D })
  hi(0, 'Keyword', { fg = gui0E })
  hi(0, 'Label', { fg = gui0A })
  hi(0, 'Number', { fg = gui09 })
  hi(0, 'Operator', { fg = gui05 })
  hi(0, 'PreProc', { fg = gui0A })
  hi(0, 'Repeat', { fg = gui0A })
  hi(0, 'Special', { fg = gui0C })
  hi(0, 'SpecialChar', { fg = gui0F })
  hi(0, 'Statement', { fg = gui08 })
  hi(0, 'StorageClass', { fg = gui0A })
  hi(0, 'String', { fg = gui0B })
  hi(0, 'Structure', { fg = gui0E })
  hi(0, 'Tag', { fg = gui0A })
  hi(0, 'Todo', { fg = gui0A, bg = gui01 })
  hi(0, 'Type', { fg = gui0A })
  hi(0, 'Typedef', { fg = gui0A })

  -- C highlighting
  hi(0, 'cOperator', { fg = gui0C })
  hi(0, 'cPreCondit', { fg = gui0E })

  -- C# highlighting
  hi(0, 'csClass', { fg = gui0A })
  hi(0, 'csAttribute', { fg = gui0A })
  hi(0, 'csModifier', { fg = gui0E })
  hi(0, 'csType', { fg = gui08 })
  hi(0, 'csUnspecifiedStatement', { fg = gui0D })
  hi(0, 'csContextualStatement', { fg = gui0E })
  hi(0, 'csNewDecleration', { fg = gui08 })

  -- CSS highlighting
  hi(0, 'cssBraces', { fg = gui05 })
  hi(0, 'cssClassName', { fg = gui0E })
  hi(0, 'cssColor', { fg = gui0C })

  -- Diff highlighting
  hi(0, 'DiffAdd', { fg = gui0B, bg = gui01 })
  hi(0, 'DiffChange', { fg = gui03, bg = gui01 })
  hi(0, 'DiffDelete', { fg = gui08, bg = gui01 })
  hi(0, 'DiffText', { fg = gui0D, bg = gui01 })
  hi(0, 'DiffAdded', { fg = gui0B, bg = gui00 })
  hi(0, 'DiffFile', { fg = gui08, bg = gui00 })
  hi(0, 'DiffNewFile', { fg = gui0B, bg = gui00 })
  hi(0, 'DiffLine', { fg = gui0D, bg = gui00 })
  hi(0, 'DiffRemoved', { fg = gui08, bg = gui00 })

  -- Git highlighting
  hi(0, 'gitcommitOverflow', { fg = gui08 })
  hi(0, 'gitcommitSummary', { fg = gui0B })
  hi(0, 'gitcommitComment', { fg = gui03 })
  hi(0, 'gitcommitUntracked', { fg = gui03 })
  hi(0, 'gitcommitDiscarded', { fg = gui03 })
  hi(0, 'gitcommitSelected', { fg = gui03 })
  hi(0, 'gitcommitHeader', { fg = gui0E })
  hi(0, 'gitcommitSelectedType', { fg = gui0D })
  hi(0, 'gitcommitUnmergedType', { fg = gui0D })
  hi(0, 'gitcommitDiscardedType', { fg = gui0D })
  hi(0, 'gitcommitBranch', { fg = gui09, bold = true })
  hi(0, 'gitcommitUntrackedFile', { fg = gui0A })
  hi(0, 'gitcommitUnmergedFile', { fg = gui08, bold = true })
  hi(0, 'gitcommitDiscardedFile', { fg = gui08, bold = true })
  hi(0, 'gitcommitSelectedFile', { fg = gui0B, bold = true })

  -- GitGutter highlighting
  hi(0, 'GitGutterAdd', { fg = gui0B, bg = sign_col_bg })
  hi(0, 'GitGutterChange', { fg = gui0D, bg = sign_col_bg })
  hi(0, 'GitGutterDelete', { fg = gui08, bg = sign_col_bg })
  hi(0, 'GitGutterChangeDelete', { fg = gui0E, bg = sign_col_bg })

  -- git-signs highlighting
  hi(0, 'GitSignsAdd', { fg = gui0B, bg = sign_col_bg })
  hi(0, 'GitSignsChange', { fg = gui0D, bg = sign_col_bg })
  hi(0, 'GitSignsDelete', { fg = gui08, bg = sign_col_bg })

  -- HTML highlighting
  hi(0, 'htmlBold', { fg = gui0A })
  hi(0, 'htmlItalic', { fg = gui0E })
  hi(0, 'htmlEndTag', { fg = gui05 })
  hi(0, 'htmlTag', { fg = gui05 })

  -- JavaScript highlighting
  hi(0, 'javaScript', { fg = gui05 })
  hi(0, 'javaScriptBraces', { fg = gui05 })
  hi(0, 'javaScriptNumber', { fg = gui09 })

  -- pangloss/vim-javascript highlighting
  hi(0, 'jsOperator', { fg = gui0D })
  hi(0, 'jsStatement', { fg = gui0E })
  hi(0, 'jsReturn', { fg = gui0E })
  hi(0, 'jsThis', { fg = gui08 })
  hi(0, 'jsClassDefinition', { fg = gui0A })
  hi(0, 'jsFunction', { fg = gui0E })
  hi(0, 'jsFuncName', { fg = gui0D })
  hi(0, 'jsFuncCall', { fg = gui0D })
  hi(0, 'jsClassFuncName', { fg = gui0D })
  hi(0, 'jsClassMethodType', { fg = gui0E })
  hi(0, 'jsRegexpString', { fg = gui0C })
  hi(0, 'jsGlobalObjects', { fg = gui0A })
  hi(0, 'jsGlobalNodeObjects', { fg = gui0A })
  hi(0, 'jsExceptions', { fg = gui0A })
  hi(0, 'jsBuiltins', { fg = gui0A })

  -- Mail highlighting
  hi(0, 'mailQuoted1', { fg = gui0A })
  hi(0, 'mailQuoted2', { fg = gui0B })
  hi(0, 'mailQuoted3', { fg = gui0E })
  hi(0, 'mailQuoted4', { fg = gui0C })
  hi(0, 'mailQuoted5', { fg = gui0D })
  hi(0, 'mailQuoted6', { fg = gui0A })
  hi(0, 'mailURL', { fg = gui0D })
  hi(0, 'mailEmail', { fg = gui0D })

  -- Markdown highlighting
  hi(0, 'markdownCode', { fg = gui0B })
  hi(0, 'markdownError', { fg = gui05, bg = gui00 })
  hi(0, 'markdownCodeBlock', { fg = gui0B })
  hi(0, 'markdownHeadingDelimiter', { fg = gui0D })

  -- NERDTree highlighting
  hi(0, 'NERDTreeDirSlash', { fg = gui0D })
  hi(0, 'NERDTreeExecFile', { fg = gui05 })

  -- PHP highlighting
  hi(0, 'phpMemberSelector', { fg = gui05 })
  hi(0, 'phpComparison', { fg = gui05 })
  hi(0, 'phpParent', { fg = gui05 })
  hi(0, 'phpMethodsVar', { fg = gui0C })

  -- Python highlighting
  hi(0, 'pythonOperator', { fg = gui0E })
  hi(0, 'pythonRepeat', { fg = gui0E })
  hi(0, 'pythonInclude', { fg = gui0E })
  hi(0, 'pythonStatement', { fg = gui0E })

  -- Ruby highlighting
  hi(0, 'rubyAttribute', { fg = gui0D })
  hi(0, 'rubyConstant', { fg = gui0A })
  hi(0, 'rubyInterpolationDelimiter', { fg = gui0F })
  hi(0, 'rubyRegexp', { fg = gui0C })
  hi(0, 'rubySymbol', { fg = gui0B })
  hi(0, 'rubyStringDelimiter', { fg = gui0B })

  -- SASS highlighting
  hi(0, 'sassidChar', { fg = gui08 })
  hi(0, 'sassClassChar', { fg = gui09 })
  hi(0, 'sassInclude', { fg = gui0E })
  hi(0, 'sassMixing', { fg = gui0E })
  hi(0, 'sassMixinName', { fg = gui0D })

  -- Signify highlighting
  hi(0, 'SignifySignAdd', { fg = gui0B, bg = gui01 })
  hi(0, 'SignifySignChange', { fg = gui0D, bg = gui01 })
  hi(0, 'SignifySignDelete', { fg = gui08, bg = gui01 })

  -- Spelling highlighting
  hi(0, 'SpellBad', { undercurl = true, sp = gui08 })
  hi(0, 'SpellLocal', { undercurl = true, sp = gui0C })
  hi(0, 'SpellCap', { undercurl = true, sp = gui0D })
  hi(0, 'SpellRare', { undercurl = true, sp = gui0E })

  -- Startify highlighting
  hi(0, 'StartifyBracket', { fg = gui03 })
  hi(0, 'StartifyFile', { fg = gui07 })
  hi(0, 'StartifyFooter', { fg = gui03 })
  hi(0, 'StartifyHeader', { fg = gui0B })
  hi(0, 'StartifyNumber', { fg = gui09 })
  hi(0, 'StartifyPath', { fg = gui03 })
  hi(0, 'StartifySection', { fg = gui0E })
  hi(0, 'StartifySelect', { fg = gui0C })
  hi(0, 'StartifySlash', { fg = gui03 })
  hi(0, 'StartifySpecial', { fg = gui03 })

  -- Java highlighting
  hi(0, 'javaOperator', { fg = gui0D })
end

return M
