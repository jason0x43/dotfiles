local colors = {
  black = {
    bg_0 = '#181818',
    bg_1 = '#252525',
    bg_2 = '#3b3b3b',
    dim_0 = '#777777',
    fg_0 = '#b9b9b9',
    fg_1 = '#dedede',
    red = '#ed4a46',
    green = '#70b433',
    yellow = '#dbb32d',
    blue = '#368aeb',
    magenta = '#eb6eb7',
    cyan = '#3fc5b7',
    br_red = '#ff5e56',
    br_green = '#83c746',
    br_yellow = '#efc541',
    br_blue = '#4f9cfe',
    br_magenta = '#ff81ca',
    br_cyan = '#56d8c9',
    orange = '#e67f43',
    violet = '#a580e2',
    br_orange = '#fa9153',
    br_violet = '#b891f5',
  },
  white = {
    bg_0 = '#ffffff',
    bg_1 = '#ebebeb',
    bg_2 = '#cdcdcd',
    dim_0 = '#878787',
    fg_0 = '#474747',
    fg_1 = '#282828',
    red = '#d6000c',
    green = '#1d9700',
    yellow = '#c49700',
    blue = '#0064e4',
    magenta = '#dd0f9d',
    cyan = '#00ad9c',
    br_red = '#bf0000',
    br_green = '#008400',
    br_yellow = '#af8500',
    br_blue = '#0054cf',
    br_magenta = '#c7008b',
    br_cyan = '#009a8a',
    orange = '#d04a00',
    violet = '#7f51d6',
    br_orange = '#ba3700',
    br_violet = '#6b40c3',
  },
  dark = {
    bg_0 = '#103c48',
    bg_1 = '#184956',
    bg_2 = '#2d5b69',
    dim_0 = '#72898f',
    fg_0 = '#adbcbc',
    fg_1 = '#cad8d9',
    red = '#fa5750',
    green = '#75b938',
    yellow = '#dbb32d',
    blue = '#4695f7',
    magenta = '#f275be',
    cyan = '#41c7b9',
    br_red = '#ff665c',
    br_green = '#84c747',
    br_yellow = '#ebc13d',
    br_blue = '#58a3ff',
    br_magenta = '#ff84cd',
    br_cyan = '#53d6c7',
    orange = '#ed8649',
    violet = '#af88eb',
    br_orange = '#fd9456',
    br_violet = '#bd96fa',
  },
  light = {
    bg_0 = '#fbf3db',
    bg_1 = '#e9e4d0',
    bg_2 = '#cfcebe',
    dim_0 = '#909995',
    fg_0 = '#53676d',
    fg_1 = '#3a4d53',
    red = '#d2212d',
    green = '#489100',
    yellow = '#ad8900',
    blue = '#0072d4',
    magenta = '#ca4898',
    cyan = '#009c8f',
    br_red = '#cc1729',
    br_green = '#428b00',
    br_yellow = '#a78300',
    br_blue = '#006dce',
    br_magenta = '#c44392',
    br_cyan = '#00978a',
    orange = '#c25d1e',
    violet = '#8762c6',
    br_orange = '#bc5819',
    br_violet = '#825dc0',
  },
}

local M = {}

function M.apply(variant)
	local c = colors[variant];

  local sign_col_bg = ''
  local hi = vim.api.nvim_set_hl

  hi(0, 'Boolean', { link = 'Constant' })
  hi(0, 'Character', { link = 'Constant' })
  hi(0, 'Conditional', { link = 'Statement' })
  hi(0, 'Debug', { link = 'Special' })
  hi(0, 'Define', { link = 'PreProc' })
  hi(0, 'ErrorMsg', { link = 'Error' })
  hi(0, 'Exception', { link = 'Statement' })
  hi(0, 'Float', { link = 'Constant' })
  hi(0, 'FloatBorder', { link = 'NormalFloat' })
  hi(0, 'Include', { link = 'PreProc' })
  hi(0, 'Keyword', { link = 'Statement' })
  hi(0, 'Label', { link = 'Statement' })
  hi(0, 'Macro', { link = 'PreProc' })
  hi(0, 'MatchParen', { link = 'MatchBackground' })
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

  hi(0, 'ColorColumn', { bg = c.bg_1 })
  hi(0, 'Comment', { fg = c.dim_0, italic = true })
  hi(0, 'Conceal', {})
  hi(0, 'Constant', { fg = c.cyan })
  hi(0, 'Cursor', { reverse = true })
  hi(0, 'CursorColumn', { bg = c.bg_1 })
  hi(0, 'CursorLine', { bg = c.bg_1 })
  hi(0, 'CursorLineNr', { fg = c.fg_1 })
  hi(0, 'Delimiter', { fg = c.fg_0 })
  hi(0, 'Directory', {})
  hi(0, 'EndOfBuffer', {})
  hi(0, 'Error', { fg = c.red, bold = true })
  hi(0, 'FoldColumn', {})
  hi(0, 'Folded', { bg = c.bg_1 })
  hi(0, 'Function', { fg = c.br_blue })
  hi(0, 'Identifier', { fg = c.violet })
  hi(0, 'Ignore', { fg = c.bg_2 })
  hi(0, 'IncSearch', { fg = c.orange, reverse = true })
  hi(0, 'LineNr', { fg = c.bg_2, bg = sign_col_bg })
  hi(0, 'ModeMsg', {})
  hi(0, 'MoreMsg', {})
  hi(0, 'NonText', {})
  hi(0, 'Normal', { fg = c.fg_0, bg = c.bg_0 })
  hi(0, 'NormalFloat', { bg = c.bg_0 })
  hi(0, 'NormalNC', { fg = c.dim_0, bg = c.bg_0 })
  hi(0, 'Pmenu', { fg = c.fg_0, bg = c.bg_1 })
  hi(0, 'PmenuSbar', { fg = c.bg_2 })
  hi(0, 'PmenuSel', { bg = c.bg_2 })
  hi(0, 'PmenuThumb', { bg = c.dim_0 })
  hi(0, 'PreProc', { fg = c.orange })
  hi(0, 'Question', {})
  hi(0, 'Search', { fg = c.yellow, reverse = true })
  hi(0, 'SignColumn', { bg = sign_col_bg })
  hi(0, 'Special', { fg = c.orange, bold = true })
  hi(0, 'SpecialKey', {})
  hi(0, 'SpellBad', { undercurl = true, sp = c.red })
  hi(0, 'SpellCap', { undercurl = true, sp = c.red })
  hi(0, 'SpellLocal', { undercurl = true, sp = c.yellow })
  hi(0, 'SpellRare', { undercurl = true, sp = c.cyan })
  hi(0, 'Statement', { fg = c.yellow })
  hi(0, 'StatusLine', { reverse = true })
  hi(0, 'StatusLineNC', { bg = c.bg_2 })
  hi(0, 'TabLine', { fg = c.dim_0, reverse = true })
  hi(0, 'TabLineFill', { fg = c.dim_0, reverse = true })
  hi(0, 'TabLineSel', { fg = c.fg_1, bg = c.bg_1, bold = true, reverse = true })
  hi(0, 'Terminal', {})
  hi(0, 'Title', { fg = c.orange, bold = true })
  hi(0, 'Todo', { fg = c.magenta, bold = true })
  hi(0, 'ToolbarButton', { reverse = true })
  hi(0, 'ToolbarLine', { bg = c.bg_2 })
  hi(0, 'Type', { fg = c.green })
  hi(0, 'Underlined', { fg = c.violet, underline = true })
  hi(0, 'VertSplit', { fg = c.dim_0, bg = c.bg_0 })
  hi(0, 'VimCommand', { fg = c.yellow })
  hi(0, 'Visual', { bg = c.bg_2 })
  hi(0, 'VisualNOS', {})
  hi(0, 'WarningMsg', {})
  hi(0, 'WildMenu', {})

  hi(0, 'DiagnosticError', { fg = c.red })
  hi(0, 'DiagnosticHint', { fg = c.dim_0 })
  hi(0, 'DiagnosticInfo', { fg = c.br_blue })
  hi(0, 'DiagnosticSignError', { fg = c.red, bg = sign_col_bg })
  hi(0, 'DiagnosticSignHint', { fg = c.dim_0, bg = sign_col_bg })
  hi(0, 'DiagnosticSignInfo', { fg = c.br_blue, bg = sign_col_bg })
  hi(0, 'DiagnosticSignWarn', { fg = c.orange, bg = sign_col_bg })
  hi(0, 'DiagnosticUnderlineError', { undercurl = true, sp = c.red })
  hi(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = c.dim_0 })
  hi(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = c.br_blue })
  hi(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = c.orange })
  hi(0, 'DiagnosticWarn', { fg = c.orange })

  hi(0, 'DiffAdd', { fg = c.green, bg = c.bg_1 })
  hi(0, 'DiffChange', { fg = c.yellow, bg = c.bg_1 })
  hi(0, 'DiffDelete', { fg = c.red, bg = c.bg_1 })
  hi(0, 'DiffText', { fg = c.bg_1, bg = c.yellow })

  hi(0, 'LspReferenceRead', { bg = c.bg_1 })
  hi(0, 'LspReferenceText', { bg = c.bg_1 })
  hi(0, 'LspReferenceWrite', { bg = c.bg_1 })

  hi(0, 'RubyDefine', { fg = c.fg_1, bold = true })

  hi(0, 'diffAdded', { fg = c.green })
  hi(0, 'diffRemoved', { fg = c.red })
  hi(0, 'diffOldFile', { fg = c.br_red })
  hi(0, 'diffNewFile', { fg = c.br_green })
  hi(0, 'diffFile', { fg = c.blue })

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

  hi(0, 'typescriptBraces', { link = 'Delimiter' })
  hi(0, 'typescriptParens', { link = 'Delimiter' })

  hi(0, 'javascriptBraces', { link = 'Delimiter' })
  hi(0, 'javascriptParens', { link = 'Delimiter' })

  hi(0, 'markdownCodeDelimiter', { link = 'PreProc' })
  hi(0, 'markdownCode', { fg = c.orange, bg = c.bg_1 })

  hi(0, 'StartifyHeader', { fg = c.green })
  hi(0, 'StartifyFile', { fg = c.blue })

  hi(0, 'DevIconBash', { fg = c.green })
  hi(0, 'DevIconBat', { fg = c.green })
  hi(0, 'DevIconJson', { fg = c.yellow })

  hi(0, 'GitSignsAdd', { fg = c.green, bg = sign_col_bg })
  hi(0, 'GitSignsChange', { fg = c.yellow, bg = sign_col_bg })
  hi(0, 'GitSignsDelete', { fg = c.red, bg = sign_col_bg })

  hi(0, 'LspDiagnosticsDefaultHint', { link = 'DiagnosticHint' })
  hi(0, 'LspDiagnosticsDefaultInformation', { link = 'DiagnosticInfo' })
  hi(0, 'LspDiagnosticsDefaultWarning', { link = 'DiagnosticWarn' })
  hi(0, 'LspDiagnosticsDefaultError', { link = 'DiagnosticError' })
  hi(0, 'LspDiagnosticsSignHint', { link = 'DiagnosticSignHint' })
  hi(0, 'LspDiagnosticsSignInformation', { link = 'DiagnosticSignInfo' })
  hi(0, 'LspDiagnosticsSignWarning', { link = 'DiagnosticSignWarn' })
  hi(0, 'LspDiagnosticsSignError', { link = 'DiagnosticSignError' })

  hi(0, 'NeoTreeFloatBorder', { link = 'Normal' })
end

return M
