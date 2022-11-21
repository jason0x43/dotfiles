local M = {}
local get_script_path = require('user.util').get_script_path
local theme_util = require('user.util.theme')

local hi = theme_util.hi
local hi_link = theme_util.hi_link

local active_palette

function M.apply()
  local g = vim.g

  g.colors_name = 'selenized'

  local theme = ""
  local theme_file = os.getenv('HOME') .. '/.local/share/wezterm/colors.json'
  if vim.fn.filereadable(theme_file) == 1 then
    local theme_data = vim.fn.readfile(theme_file)
    theme = vim.fn.json_decode(theme_data)
  else
    local dirname = get_script_path()
    local theme_data = vim.fn.readfile(dirname .. '/themes.json')
    local themes = vim.fn.json_decode(theme_data)
    theme = themes[vim.go.background]
  end

  local palette = theme
  active_palette = theme

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
  hi('Normal', palette.fg_0, palette.bg_0, '', '')
  hi('NormalNC', palette.dim_0, palette.bg_0)
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
  hi('DiagnosticSignHint', palette.dim_0, sign_col_bg)
  hi('DiagnosticWarn', palette.orange)
  hi('DiagnosticSignWarn', palette.orange, sign_col_bg)
  hi('DiagnosticError', palette.red)
  hi('DiagnosticSignError', palette.red, sign_col_bg)
  hi('DiagnosticInfo', palette.br_blue)
  hi('DiagnosticSignInfo', palette.br_blue, sign_col_bg)
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
  hi('LineNr', palette.bg_2, sign_col_bg, '', '')
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
  hi('SignColumn', '', sign_col_bg, '', '')
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
  hi('VertSplit', palette.dim_0, palette.bg_0, '')
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
  hi('markdownCode', palette.orange, palette.bg_1)

  -- Startify
  hi('StartifyHeader', palette.green)
  hi('StartifyFile', palette.blue)

  -- devicons
  hi('DevIconBash', palette.green)
  hi('DevIconBat', palette.green)
  hi('DevIconJson', palette.yellow)

  -- gitsigns
  hi('GitSignsAdd', palette.green, sign_col_bg)
  hi('GitSignsChange', palette.yellow, sign_col_bg)
  hi('GitSignsDelete', palette.red, sign_col_bg)

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

function M.active_palette()
  return active_palette
end

return M
