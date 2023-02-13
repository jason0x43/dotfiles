local theme_util = require('user.util.theme')

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
  local hi = vim.api.nvim_set_hl

  -- link groups
  hi(0, 'Boolean', { link = 'Constant' })
  hi(0, 'Character', { link = 'Constant' })
  hi(0, 'Conditional', { link = 'Statement' })
  hi(0, 'Debug', { link = 'Special' })
  hi(0, 'Define', { link = 'PreProc' })
  hi(0, 'Exception', { link = 'Statement' })
  hi(0, 'Float', { link = 'Constant' })
  hi(0, 'FloatBorder', { link = 'NormalFloat' })
  hi(0, 'Include', { link = 'PreProc' })
  hi(0, 'Keyword', { link = 'Statement' })
  hi(0, 'Label', { link = 'Statement' })
  hi(0, 'Macro', { link = 'PreProc' })
  hi(0, 'Number', { link = 'Constant' })
  hi(0, 'Operator', { link = 'Statement' })
  hi(0, 'PreCondit', { link = 'PreProc' })
  hi(0, 'QuickFixLine', { link = 'Search' })
  hi(0, 'Repeat', { link = 'Statement' })
  hi(0, 'SpecialChar', { link = 'Special' })
  hi(0, 'SpecialComment', { link = 'Special' })
  hi(0, 'StatusLineTerm', { link = 'StatusLine' })
  hi(0, 'StatusLineTermNC', { link = 'StatusLineNC' })
  hi(0, 'StorageClass', { link = 'Type' })
  hi(0, 'String', { link = 'Constant' })
  hi(0, 'Structure', { link = 'Type' })
  hi(0, 'Tag', { link = 'Special' })
  hi(0, 'Typedef', { link = 'Type' })
  hi(0, 'lCursor', { link = 'Cursor' })
  hi(0, 'ErrorMsg', { link = 'Error' })
  hi(0, 'MatchParen', { link = 'MatchBackground' })

  -- basic groups
  hi(0, 'Normal', { fg = fg_0, bg = bg_0 })
  hi(0, 'NormalNC', { fg = dim_0, bg = bg_0 })
  hi(0, 'Comment', { fg = dim_0, italic = true })
  hi(0, 'Constant', { fg = cyan })
  hi(0, 'Delimiter', { fg = fg_0 })
  hi(0, 'Function', { fg = br_blue })
  hi(0, 'Identifier', { fg = violet })
  hi(0, 'Statement', { fg = yellow })
  hi(0, 'PreProc', { fg = orange })
  hi(0, 'Type', { fg = green })
  hi(0, 'Special', { fg = orange, bold = true })
  hi(0, 'Underlined', { fg = violet, underline = true })
  hi(0, 'Ignore', { fg = bg_2 })
  hi(0, 'Error', { fg = red, bold = true })
  hi(0, 'Todo', { fg = magenta, bold = true })

  -- extended groups
  hi(0, 'ColorColumn', { bg = bg_1 })
  hi(0, 'Conceal', {})
  hi(0, 'Cursor', { reverse = true })
  hi(0, 'CursorColumn', { bg = bg_1 })
  hi(0, 'CursorLine', { bg = bg_1 })
  hi(0, 'CursorLineNr', { fg = fg_1 })
  hi(0, 'DiagnosticHint', { fg = dim_0 })
  hi(0, 'DiagnosticSignHint', { fg = dim_0, bg = sign_col_bg })
  hi(0, 'DiagnosticWarn', { fg = orange })
  hi(0, 'DiagnosticSignWarn', { fg = orange, bg = sign_col_bg })
  hi(0, 'DiagnosticError', { fg = red })
  hi(0, 'DiagnosticSignError', { fg = red, bg = sign_col_bg })
  hi(0, 'DiagnosticInfo', { fg = br_blue })
  hi(0, 'DiagnosticSignInfo', { fg = br_blue, bg = sign_col_bg })
  hi(0, 'DiagnosticUnderlineError', { undercurl = true, sp = red })
  hi(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = dim_0 })
  hi(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = orange })
  hi(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = br_blue })
  hi(0, 'DiffAdd', { fg = green, bg = bg_1 })
  hi(0, 'DiffChange', { fg = yellow, bg = bg_1 })
  hi(0, 'DiffDelete', { fg = red, bg = bg_1 })
  hi(0, 'DiffText', { fg = bg_1, bg = yellow })
  hi(0, 'Directory', {})
  hi(0, 'EndOfBuffer', {})
  hi(0, 'FoldColumn', {})
  hi(0, 'Folded', { bg = bg_1 })
  hi(0, 'IncSearch', { fg = orange, reverse = true })
  hi(0, 'LineNr', { fg = bg_2, bg = sign_col_bg })
  hi(0, 'LspReferenceRead', { bg = bg_1 })
  hi(0, 'LspReferenceText', { bg = bg_1 })
  hi(0, 'LspReferenceWrite', { bg = bg_1 })
  hi(0, 'ModeMsg', {})
  hi(0, 'MoreMsg', {})
  hi(0, 'NonText', {})
  hi(0, 'NormalFloat', { bg = bg_0 })
  hi(0, 'Pmenu', { fg = fg_0, bg = bg_1 })
  hi(0, 'PmenuSbar', { fg = bg_2 })
  hi(0, 'PmenuSel', { bg = bg_2 })
  hi(0, 'PmenuThumb', { bg = dim_0 })
  hi(0, 'Question', {})
  hi(0, 'RubyDefine', { fg = fg_1, bold = true })
  hi(0, 'Search', { fg = yellow, reverse = true })
  hi(0, 'SignColumn', { bg = sign_col_bg })
  hi(0, 'SpecialKey', {})
  hi(0, 'SpellBad', { undercurl = true, sp = red })
  hi(0, 'SpellCap', { undercurl = true, sp = red })
  hi(0, 'SpellLocal', { undercurl = true, sp = yellow })
  hi(0, 'SpellRare', { undercurl = true, sp = cyan })
  hi(0, 'StatusLine', { reverse = true })
  hi(0, 'StatusLineNC', { bg = bg_2 })
  hi(0, 'TabLine', { fg = dim_0, reverse = true })
  hi(0, 'TabLineFill', { fg = dim_0, reverse = true })
  hi(0, 'TabLineSel', { fg = fg_1, bg = bg_1, bold = true, reverse = true })
  hi(0, 'Terminal', {})
  hi(0, 'Title', { fg = orange, bold = true })
  hi(0, 'ToolbarButton', { reverse = true })
  hi(0, 'ToolbarLine', { bg = bg_2 })
  hi(0, 'VertSplit', { fg = dim_0, bg = bg_0 })
  hi(0, 'VimCommand', { fg = yellow })
  hi(0, 'Visual', { bg = bg_2 })
  hi(0, 'VisualNOS', {})
  hi(0, 'WarningMsg', {})
  hi(0, 'WildMenu', {})
  hi(0, 'diffAdded', { fg = green })
  hi(0, 'diffRemoved', { fg = red })
  hi(0, 'diffOldFile', { fg = br_red })
  hi(0, 'diffNewFile', { fg = br_green })
  hi(0, 'diffFile', { fg = blue })

  -- override some of the default treesitter links
  hi(0, 'TSConstBuiltin', { link = 'Constant' })
  hi(0, 'TSConstMacro', { link = 'Constant' })
  hi(0, 'TSFuncBuiltin', { link = 'Function' })
  hi(0, 'TSConstructor', { link = 'Function' })
  hi(0, '@tag', { link = 'Statement' })
  hi(0, '@tag.delimiter', { link = 'Delimiter' })
  hi(0, '@tag.attribute', { link = 'Type' })
  hi(0, '@operator', { link = 'PreProc' })
  hi(0, '@string', { link = 'Constant' })
  hi(0, '@variable', { link = 'Identifier' })
  hi(0, '@keyword', { link = 'Keyword' })

  -- TypeScript
  hi(0, 'typescriptBraces', { link = 'Delimiter' })
  hi(0, 'typescriptParens', { link = 'Delimiter' })

  -- JavaScript
  hi(0, 'javascriptBraces', { link = 'Delimiter' })
  hi(0, 'javascriptParens', { link = 'Delimiter' })

  -- Markdown
  hi(0, 'markdownCodeDelimiter', { link = 'PreProc' })
  hi(0, 'markdownCode', { fg = orange, bg = bg_1 })

  -- Startify
  hi(0, 'StartifyHeader', { fg = green })
  hi(0, 'StartifyFile', { fg = blue })

  -- devicons
  hi(0, 'DevIconBash', { fg = green })
  hi(0, 'DevIconBat', { fg = green })
  hi(0, 'DevIconJson', { fg = yellow })

  -- gitsigns
  hi(0, 'GitSignsAdd', { fg = green, bg = sign_col_bg })
  hi(0, 'GitSignsChange', { fg = yellow, bg = sign_col_bg })
  hi(0, 'GitSignsDelete', { fg = red, bg = sign_col_bg })

  -- telescope
  hi(0, 'LspDiagnosticsDefaultHint', { link = 'DiagnosticHint' })
  hi(0, 'LspDiagnosticsDefaultInformation', { link = 'DiagnosticInfo' })
  hi(0, 'LspDiagnosticsDefaultWarning', { link = 'DiagnosticWarn' })
  hi(0, 'LspDiagnosticsDefaultError', { link = 'DiagnosticError' })
  hi(0, 'LspDiagnosticsSignHint', { link = 'DiagnosticSignHint' })
  hi(0, 'LspDiagnosticsSignInformation', { link = 'DiagnosticSignInfo' })
  hi(0, 'LspDiagnosticsSignWarning', { link = 'DiagnosticSignWarn' })
  hi(0, 'LspDiagnosticsSignError', { link = 'DiagnosticSignError' })

  -- neotree
  hi(0, 'NeoTreeFloatBorder', { link = 'Normal' })
end

return M
