local M = {}
local hi = require('util.theme').hi
local hi_link = require('util.theme').hi_link
local augroup = require('util').augroup

local palettes = {
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
}

local active_palette

function M.apply_theme(theme_name)
  local g = vim.g

  g.colors_name = 'selenized'

  if theme_name == 'light' or theme_name == 'white' then
    vim.go.background = 'light'
  else
    vim.go.background = 'dark'
  end

  local palette = palettes[theme_name]
  active_palette = palette

  g.terminal_color_0 = palette.bg_1
  g.terminal_color_1 = palette.red
  g.terminal_color_2 = palette.green
  g.terminal_color_3 = palette.yellow
  g.terminal_color_4 = palette.blue
  g.terminal_color_5 = palette.magenta
  g.terminal_color_6 = palette.cyan
  g.terminal_color_7 = palette.dim_0
  g.terminal_color_8 = palette.bg_2
  g.terminal_color_9 = palette.br_red
  g.terminal_color_10 = palette.br_green
  g.terminal_color_11 = palette.br_yellow
  g.terminal_color_12 = palette.br_blue
  g.terminal_color_13 = palette.br_magenta
  g.terminal_color_14 = palette.br_cyan
  g.terminal_color_15 = palette.fg_1

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
  hi('Normal', palette.fg_0, palette.bg_0, '', '')
  hi('NormalNC', palette.fg_0, palette.bg_1, '', '')
  hi('Comment', palette.dim_0, '', 'italic', '')
  hi('Constant', palette.cyan, '', '', '')
  hi('Delimiter', palette.fg_0, '', '', '')
  hi('Function', palette.br_blue, '', '', '')
  hi('Identifier', palette.violet, '', '', '')
  hi('Statement', palette.yellow, '', '', '')
  hi('PreProc', palette.orange, '', '', '')
  hi('Type', palette.green, '', '', '')
  hi('Special', palette.orange, '', 'bold', '')
  hi('Underlined', palette.violet, '', 'underline', '')
  hi('Ignore', palette.bg_2, '', '', '')
  hi('Error', palette.red, '', 'bold', '')
  hi('Todo', palette.magenta, '', 'bold', '')

  -- extended groups
  hi('ColorColumn', '', palette.bg_1, '', '')
  hi('Conceal', '', '', '', '')
  hi('Cursor', '', '', 'reverse', '')
  hi('CursorColumn', '', palette.bg_1, '', '')
  hi('CursorLine', '', palette.bg_1, '', '')
  hi('CursorLineNr', palette.fg_1, '', '', '')
  hi('DiagnosticHint', palette.dim_0)
  hi('DiagnosticSignHint', palette.dim_0, palette.bg_1)
  hi('DiagnosticWarn', palette.orange)
  hi('DiagnosticSignWarn', palette.orange, palette.bg_1)
  hi('DiagnosticError', palette.red)
  hi('DiagnosticSignError', palette.red, palette.bg_1)
  hi('DiagnosticInfo', palette.br_blue)
  hi('DiagnosticSignInfo', palette.br_blue, palette.bg_1)
  hi('DiagnosticUnderlineError', { gui = 'undercurl', sp = palette.red })
  hi('DiagnosticUnderlineHint', { gui = 'undercurl', sp = palette.dim_0 })
  hi('DiagnosticUnderlineWarn', { gui = 'undercurl', sp = palette.orange })
  hi('DiagnosticUnderlineInfo', { gui = 'undercurl', sp = palette.br_blue })
  hi('DiffAdd', palette.green, palette.bg_1, '', '')
  hi('DiffChange', palette.yellow, palette.bg_1, '', '')
  hi('DiffDelete', palette.red, palette.bg_1, '', '')
  hi('DiffText', palette.bg_1, palette.yellow, '', '')
  hi('Directory', '', '', '', '')
  hi('EndOfBuffer', '', '', '', '')
  hi('FoldColumn', '', '', '', '')
  hi('Folded', '', palette.bg_1, '', '')
  hi('IncSearch', palette.orange, '', 'reverse', '')
  hi('LineNr', palette.dim_0, palette.bg_1, '', '')
  hi('LspReferenceRead', nil, palette.bg_1)
  hi('LspReferenceText', nil, palette.bg_1)
  hi('LspReferenceWrite', nil, palette.bg_1)
  hi('ModeMsg', '', '', '', '')
  hi('MoreMsg', '', '', '', '')
  hi('NonText', '', '', '', '')
  hi('NormalFloat', '', palette.bg_0, '', '')
  hi('Pmenu', palette.fg_0, palette.bg_1, '', '')
  hi('PmenuSbar', '', palette.bg_2, '', '')
  hi('PmenuSel', '', palette.bg_2, '', '')
  hi('PmenuThumb', '', palette.dim_0, '', '')
  hi('Question', '', '', '', '')
  hi('RubyDefine', palette.fg_1, '', 'bold', '')
  hi('Search', palette.yellow, '', 'reverse', '')
  hi('SignColumn', '', palette.bg_1, '', '')
  hi('SpecialKey', '', '', '', '')
  hi('SpellBad', '', '', 'undercurl', palette.red)
  hi('SpellCap', '', '', 'undercurl', palette.red)
  hi('SpellLocal', '', '', 'undercurl', palette.yellow)
  hi('SpellRare', '', '', 'undercurl', palette.cyan)
  hi('StatusLine', '', '', 'reverse', '')
  hi('StatusLineNC', '', palette.bg_2, '', '')
  hi('TabLine', palette.dim_0, '', 'reverse', '')
  hi('TabLineFill', palette.dim_0, '', 'reverse', '')
  hi('TabLineSel', palette.fg_1, palette.bg_1, 'bold,reverse', '')
  hi('Terminal', '', '', '', '')
  hi('Title', palette.orange, '', 'bold', '')
  hi('ToolbarButton', '', '', 'reverse', '')
  hi('ToolbarLine', '', palette.bg_2, '', '')
  hi('VertSplit', palette.dim_0, palette.bg_1, '')
  hi('VimCommand', palette.yellow, '', '', '')
  hi('Visual', '', palette.bg_2, '', '')
  hi('VisualNOS', '', '', '', '')
  hi('WarningMsg', '', '', '', '')
  hi('WildMenu', '', '', '', '')
  hi('diffAdded', palette.green, '', '', '')
  hi('diffRemoved', palette.red, '', '', '')
  hi('diffOldFile', palette.br_red, '', '', '')
  hi('diffNewFile', palette.br_green, '', '', '')
  hi('diffFile', palette.blue, '', '', '')

  -- override some of the default treesitter links
  hi_link('TSConstBuiltin', 'Constant')
  hi_link('TSConstMacro', 'Constant')
  hi_link('TSFuncBuiltin', 'Function')
  hi_link('TSConstructor', 'Function')

  -- TypeScript
  hi_link('typescriptBraces', 'Delimiter')
  hi_link('typescriptParens', 'Delimiter')

  -- JavaScript
  hi_link('javascriptBraces', 'Delimiter')
  hi_link('javascriptParens', 'Delimiter')

  -- Markdown
  hi_link('markdownCodeDelimiter', 'PreProc')
  hi_link('markdownCode', 'Visual')

  -- Startify
  hi('StartifyHeader', palette.green)
  hi('StartifyFile', palette.blue)

  -- devicons
  hi('DevIconBash', palette.green)
  hi('DevIconBat', palette.green)
  hi('DevIconJson', palette.yellow)

  -- gitsigns
  hi('GitSignsAdd', palette.green, palette.bg_1)
  hi('GitSignsChange', palette.yellow, palette.bg_1)
  hi('GitSignsDelete', palette.red, palette.bg_1)

  -- telescope
  hi_link('LspDiagnosticsDefaultHint', 'DiagnosticHint')
  hi_link('LspDiagnosticsDefaultInformation', 'DiagnosticInfo')
  hi_link('LspDiagnosticsDefaultWarning', 'DiagnosticWarn')
  hi_link('LspDiagnosticsDefaultError', 'DiagnosticError')
  hi_link('LspDiagnosticsSignHint', 'DiagnosticSignHint')
  hi_link('LspDiagnosticsSignInformation', 'DiagnosticSignInfo')
  hi_link('LspDiagnosticsSignWarning', 'DiagnosticSignWarn')
  hi_link('LspDiagnosticsSignError', 'DiagnosticSignError')

  -- update the theme background when focus is gained or lost, as tmux does
  augroup('selenized-theme', {
    'FocusLost * lua require("colors.selenized").update_background(false)',
    'FocusGained * lua require("colors.selenized").update_background(true)',
  })
end

function M.update_background(focused)
  local ap = active_palette
  if focused then
    hi('Normal', ap.fg_0, ap.bg_0, '', '')
  else
    hi('Normal', ap.fg_0, ap.bg_1, '', '')
  end
end

function M.active_palette()
  return active_palette
end

return M
