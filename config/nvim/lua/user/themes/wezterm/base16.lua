local M = {}

function M.apply(colors)
  local base00 = colors.color00
  local base01 = colors.color18 or colors.color08
  local base02 = colors.color19 or colors.color11
  local base03 = colors.color08
  local base04 = colors.color20 or colors.color12
  local base05 = colors.color07
  local base06 = colors.color21 or colors.color13
  local base07 = colors.color15
  local base08 = colors.color01
  local base09 = colors.color16 or colors.color09
  local base0A = colors.color03
  local base0B = colors.color02
  local base0C = colors.color06
  local base0D = colors.color04
  local base0E = colors.color05
  local base0F = colors.color17 or colors.color14

  local sign_col_bg = base01

  local hi = vim.api.nvim_set_hl
	local util = require('user.util.theme')

	if util.is_dark(base00) then
		vim.go.background = 'dark'
	else
		vim.go.background = 'light'
	end

  hi(0, 'Bold', { bold = true })
  hi(0, 'Boolean', { fg = base09 })
  hi(0, 'Character', { fg = base08 })
  hi(0, 'ColorColumn', { bg = base01 })
  hi(0, 'Comment', { fg = base03 })
  hi(0, 'Conceal', { fg = base0D, bg = base00 })
  hi(0, 'Conditional', { fg = base0E })
  hi(0, 'Constant', { fg = base09 })
  hi(0, 'Cursor', { fg = base00, bg = base05 })
  hi(0, 'CursorColumn', { bg = base01 })
  hi(0, 'CursorLine', { bg = base01 })
  hi(0, 'CursorLineNr', { fg = base04, bg = sign_col_bg })
  hi(0, 'Debug', { fg = base08 })
  hi(0, 'Define', { fg = base0E })
  hi(0, 'Delimiter', { fg = base0F })
  hi(0, 'Directory', { fg = base0D })
  hi(0, 'Error', { fg = base00, bg = base08 })
  hi(0, 'ErrorMsg', { fg = base08, bg = base00 })
  hi(0, 'Exception', { fg = base08 })
  hi(0, 'Float', { fg = base09 })
  hi(0, 'FoldColumn', { fg = base0C, bg = base01 })
  hi(0, 'Folded', { fg = base03, bg = base01 })
  hi(0, 'Function', { fg = base0D })
  hi(0, 'Identifier', { fg = base08 })
  hi(0, 'IncSearch', { fg = base01, bg = base09 })
  hi(0, 'Include', { fg = base0D })
  hi(0, 'Italic', { italic = true })
  hi(0, 'Keyword', { fg = base0E })
  hi(0, 'Label', { fg = base0A })
  hi(0, 'LineNr', { fg = base03, bg = sign_col_bg })
  hi(0, 'Macro', { fg = base08 })
  hi(0, 'MatchParen', { bg = base03 })
  hi(0, 'ModeMsg', { fg = base0B })
  hi(0, 'MoreMsg', { fg = base0B })
  hi(0, 'NonText', { fg = base03 })
  hi(0, 'Normal', { fg = base05, bg = base00 })
  hi(0, 'Number', { fg = base09 })
  hi(0, 'Operator', { fg = base05 })
  hi(0, 'PMenu', { fg = base05, bg = base01 })
  hi(0, 'PMenuSel', { fg = base01, bg = base05 })
  hi(0, 'PreProc', { fg = base0A })
  hi(0, 'Question', { fg = base0D })
  hi(0, 'QuickFixLine', { bg = base01 })
  hi(0, 'Repeat', { fg = base0A })
  hi(0, 'Search', { fg = base01, bg = base0A })
  hi(0, 'SignColumn', { fg = base03, bg = sign_col_bg })
  hi(0, 'Special', { fg = base0C })
  hi(0, 'SpecialChar', { fg = base0F })
  hi(0, 'SpecialKey', { fg = base03 })
  hi(0, 'Statement', { fg = base08 })
  hi(0, 'StatusLine', { fg = base04, bg = base02 })
  hi(0, 'StatusLineNC', { fg = base03, bg = base01 })
  hi(0, 'StorageClass', { fg = base0A })
  hi(0, 'String', { fg = base0B })
  hi(0, 'Structure', { fg = base0E })
  hi(0, 'Substitute', { fg = base01, bg = base0A })
  hi(0, 'TabLine', { fg = base03, bg = base01 })
  hi(0, 'TabLineFill', { fg = base03, bg = base01 })
  hi(0, 'TabLineSel', { fg = base0B, bg = base01 })
  hi(0, 'Tag', { fg = base0A })
  hi(0, 'Title', { fg = base0D })
  hi(0, 'Todo', { fg = base0A, bg = base01 })
  hi(0, 'TooLong', { fg = base08 })
  hi(0, 'Type', { fg = base0A })
  hi(0, 'Typedef', { fg = base0A })
  hi(0, 'Underlined', { fg = base08 })
  hi(0, 'VertSplit', { fg = base02, bg = base02 })
  hi(0, 'Visual', { fg = base02 })
  hi(0, 'VisualNOS', { fg = base08 })
  hi(0, 'WarningMsg', { fg = base08 })
  hi(0, 'WildMenu', { fg = base08, bg = base0A })

  hi(0, 'DiagnosticSignError', { fg = base08, bg = sign_col_bg })
  hi(0, 'DiagnosticSignHint', { fg = base03, bg = sign_col_bg })
  hi(0, 'DiagnosticSignInfo', { fg = base0D, bg = sign_col_bg })
  hi(0, 'DiagnosticSignWarn', { fg = base0A, bg = sign_col_bg })

  -- C highlighting
  hi(0, 'cOperator', { fg = base0C })
  hi(0, 'cPreCondit', { fg = base0E })

  -- C# highlighting
  hi(0, 'csClass', { fg = base0A })
  hi(0, 'csAttribute', { fg = base0A })
  hi(0, 'csModifier', { fg = base0E })
  hi(0, 'csType', { fg = base08 })
  hi(0, 'csUnspecifiedStatement', { fg = base0D })
  hi(0, 'csContextualStatement', { fg = base0E })
  hi(0, 'csNewDecleration', { fg = base08 })

  -- CSS highlighting
  hi(0, 'cssBraces', { fg = base05 })
  hi(0, 'cssClassName', { fg = base0E })
  hi(0, 'cssColor', { fg = base0C })

  -- Diff highlighting
  hi(0, 'DiffAdd', { fg = base0B, bg = base01 })
  hi(0, 'DiffChange', { fg = base03, bg = base01 })
  hi(0, 'DiffDelete', { fg = base08, bg = base01 })
  hi(0, 'DiffText', { fg = base0D, bg = base01 })
  hi(0, 'DiffAdded', { fg = base0B, bg = base00 })
  hi(0, 'DiffFile', { fg = base08, bg = base00 })
  hi(0, 'DiffNewFile', { fg = base0B, bg = base00 })
  hi(0, 'DiffLine', { fg = base0D, bg = base00 })
  hi(0, 'DiffRemoved', { fg = base08, bg = base00 })

  -- Git highlighting
  hi(0, 'gitcommitOverflow', { fg = base08 })
  hi(0, 'gitcommitSummary', { fg = base0B })
  hi(0, 'gitcommitComment', { fg = base03 })
  hi(0, 'gitcommitUntracked', { fg = base03 })
  hi(0, 'gitcommitDiscarded', { fg = base03 })
  hi(0, 'gitcommitSelected', { fg = base03 })
  hi(0, 'gitcommitHeader', { fg = base0E })
  hi(0, 'gitcommitSelectedType', { fg = base0D })
  hi(0, 'gitcommitUnmergedType', { fg = base0D })
  hi(0, 'gitcommitDiscardedType', { fg = base0D })
  hi(0, 'gitcommitBranch', { fg = base09, bold = true })
  hi(0, 'gitcommitUntrackedFile', { fg = base0A })
  hi(0, 'gitcommitUnmergedFile', { fg = base08, bold = true })
  hi(0, 'gitcommitDiscardedFile', { fg = base08, bold = true })
  hi(0, 'gitcommitSelectedFile', { fg = base0B, bold = true })

  -- GitGutter highlighting
  hi(0, 'GitGutterAdd', { fg = base0B, bg = sign_col_bg })
  hi(0, 'GitGutterChange', { fg = base0D, bg = sign_col_bg })
  hi(0, 'GitGutterDelete', { fg = base08, bg = sign_col_bg })
  hi(0, 'GitGutterChangeDelete', { fg = base0E, bg = sign_col_bg })

  -- git-signs highlighting
  hi(0, 'GitSignsAdd', { fg = base0B, bg = sign_col_bg })
  hi(0, 'GitSignsChange', { fg = base0D, bg = sign_col_bg })
  hi(0, 'GitSignsDelete', { fg = base08, bg = sign_col_bg })

  -- HTML highlighting
  hi(0, 'htmlBold', { fg = base0A })
  hi(0, 'htmlItalic', { fg = base0E })
  hi(0, 'htmlEndTag', { fg = base05 })
  hi(0, 'htmlTag', { fg = base05 })

  -- JavaScript highlighting
  hi(0, 'javaScript', { fg = base05 })
  hi(0, 'javaScriptBraces', { fg = base05 })
  hi(0, 'javaScriptNumber', { fg = base09 })

  -- pangloss/vim-javascript highlighting
  hi(0, 'jsOperator', { fg = base0D })
  hi(0, 'jsStatement', { fg = base0E })
  hi(0, 'jsReturn', { fg = base0E })
  hi(0, 'jsThis', { fg = base08 })
  hi(0, 'jsClassDefinition', { fg = base0A })
  hi(0, 'jsFunction', { fg = base0E })
  hi(0, 'jsFuncName', { fg = base0D })
  hi(0, 'jsFuncCall', { fg = base0D })
  hi(0, 'jsClassFuncName', { fg = base0D })
  hi(0, 'jsClassMethodType', { fg = base0E })
  hi(0, 'jsRegexpString', { fg = base0C })
  hi(0, 'jsGlobalObjects', { fg = base0A })
  hi(0, 'jsGlobalNodeObjects', { fg = base0A })
  hi(0, 'jsExceptions', { fg = base0A })
  hi(0, 'jsBuiltins', { fg = base0A })

  -- Mail highlighting
  hi(0, 'mailQuoted1', { fg = base0A })
  hi(0, 'mailQuoted2', { fg = base0B })
  hi(0, 'mailQuoted3', { fg = base0E })
  hi(0, 'mailQuoted4', { fg = base0C })
  hi(0, 'mailQuoted5', { fg = base0D })
  hi(0, 'mailQuoted6', { fg = base0A })
  hi(0, 'mailURL', { fg = base0D })
  hi(0, 'mailEmail', { fg = base0D })

  -- Markdown highlighting
  hi(0, 'markdownCode', { fg = base0B })
  hi(0, 'markdownError', { fg = base05, bg = base00 })
  hi(0, 'markdownCodeBlock', { fg = base0B })
  hi(0, 'markdownHeadingDelimiter', { fg = base0D })

  -- NERDTree highlighting
  hi(0, 'NERDTreeDirSlash', { fg = base0D })
  hi(0, 'NERDTreeExecFile', { fg = base05 })

  -- PHP highlighting
  hi(0, 'phpMemberSelector', { fg = base05 })
  hi(0, 'phpComparison', { fg = base05 })
  hi(0, 'phpParent', { fg = base05 })
  hi(0, 'phpMethodsVar', { fg = base0C })

  -- Python highlighting
  hi(0, 'pythonOperator', { fg = base0E })
  hi(0, 'pythonRepeat', { fg = base0E })
  hi(0, 'pythonInclude', { fg = base0E })
  hi(0, 'pythonStatement', { fg = base0E })

  -- Ruby highlighting
  hi(0, 'rubyAttribute', { fg = base0D })
  hi(0, 'rubyConstant', { fg = base0A })
  hi(0, 'rubyInterpolationDelimiter', { fg = base0F })
  hi(0, 'rubyRegexp', { fg = base0C })
  hi(0, 'rubySymbol', { fg = base0B })
  hi(0, 'rubyStringDelimiter', { fg = base0B })

  -- SASS highlighting
  hi(0, 'sassidChar', { fg = base08 })
  hi(0, 'sassClassChar', { fg = base09 })
  hi(0, 'sassInclude', { fg = base0E })
  hi(0, 'sassMixing', { fg = base0E })
  hi(0, 'sassMixinName', { fg = base0D })

  -- Signify highlighting
  hi(0, 'SignifySignAdd', { fg = base0B, bg = base01 })
  hi(0, 'SignifySignChange', { fg = base0D, bg = base01 })
  hi(0, 'SignifySignDelete', { fg = base08, bg = base01 })

  -- Spelling highlighting
  hi(0, 'SpellBad', { undercurl = true, sp = base08 })
  hi(0, 'SpellLocal', { undercurl = true, sp = base0C })
  hi(0, 'SpellCap', { undercurl = true, sp = base0D })
  hi(0, 'SpellRare', { undercurl = true, sp = base0E })

  -- Startify highlighting
  hi(0, 'StartifyBracket', { fg = base03 })
  hi(0, 'StartifyFile', { fg = base07 })
  hi(0, 'StartifyFooter', { fg = base03 })
  hi(0, 'StartifyHeader', { fg = base0B })
  hi(0, 'StartifyNumber', { fg = base09 })
  hi(0, 'StartifyPath', { fg = base03 })
  hi(0, 'StartifySection', { fg = base0E })
  hi(0, 'StartifySelect', { fg = base0C })
  hi(0, 'StartifySlash', { fg = base03 })
  hi(0, 'StartifySpecial', { fg = base03 })

  -- Java highlighting
  hi(0, 'javaOperator', { fg = base0D })
end

return M
