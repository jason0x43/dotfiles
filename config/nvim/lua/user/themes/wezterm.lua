local os = require('os')

---@alias Palette
---| { bg_0: string, bg_1: string, bg_2: string, dim_0: string, fg_0: string, fg_1: string, red: string, green: string, yellow: string, blue: string, magenta: string, cyan: string, br_red: string, br_green: string, br_yellow: string, br_blue: string, br_magenta: string, br_cyan: string, orange: string, br_orange: string, violet: string, br_violet: string }
---@alias CtermPalette
---| { bg_0: number | nil, bg_1: number | nil, bg_2: number | nil, dim_0: number | nil, fg_0: number | nil, fg_1: number | nil, red: number | nil, green: number | nil, yellow: number | nil, blue: number | nil, magenta: number | nil, cyan: number | nil, br_red: number | nil, br_green: number | nil, br_yellow: number | nil, br_blue: number | nil, br_magenta: number | nil, br_cyan: number | nil, orange: number | nil, br_orange: number | nil, violet: number | nil, br_violet: number | nil }

-- Default color palettes in the Selenized format
---@type { [string]: Palette }
local palettes = {
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

local cterm_palette = {
    bg_0 = nil,
    fg_0 = nil,
    bg_1 = 0,
    red = 1,
    green = 2,
    yellow = 3,
    blue = 4,
    magenta = 5,
    cyan = 6,
    dim_0 = 7,
    bg_2 = 8,
    br_red = 9,
    br_green = 10,
    br_yellow = 11,
    br_blue = 12,
    br_magenta = 13,
    br_cyan = 14,
    fg_1 = 15,
    orange = 16,
    br_orange = 17,
    violet = 18,
    br_violet = 19,
}

-- Convert a Wezterm color scheme to the Selenized format.
--
-- This function assumes a scheme that follows standard XTerm conventions, with
-- 2 extra dark + bright colors in the 16-19 indexes
---@param wezterm_colors table
---@return Palette
local function to_selenized(wezterm_colors)
  return {
    bg_0 = wezterm_colors.background,
    bg_1 = wezterm_colors.ansi['1'],
    bg_2 = wezterm_colors.brights['1'],
    dim_0 = wezterm_colors.ansi['8'],
    fg_0 = wezterm_colors.foreground,
    fg_1 = wezterm_colors.brights['8'],
    red = wezterm_colors.ansi['2'],
    green = wezterm_colors.ansi['3'],
    yellow = wezterm_colors.ansi['4'],
    blue = wezterm_colors.ansi['5'],
    magenta = wezterm_colors.ansi['6'],
    cyan = wezterm_colors.ansi['7'],
    br_red = wezterm_colors.brights['2'],
    br_green = wezterm_colors.brights['3'],
    br_yellow = wezterm_colors.brights['4'],
    br_blue = wezterm_colors.brights['5'],
    br_magenta = wezterm_colors.brights['6'],
    br_cyan = wezterm_colors.brights['7'],
    orange = wezterm_colors.indexed['16'],
    br_orange = wezterm_colors.indexed['17'],
    violet = wezterm_colors.indexed['18'],
    br_violet = wezterm_colors.indexed['19'],
  }
end

-- A convenience function for linking highlight groups
---@param group string
---@param other_group string
local function hilink(group, other_group)
  vim.api.nvim_set_hl(0, group, { link = other_group })
end

-- Apply a theme in the Selenized format
---@param c Palette | CtermPalette
local function apply_theme(c)
  -- A convenience function for setting highlight groups
  local hi = nil
  if vim.go.termguicolors then
    ---@param group string
    ---@param options table
    hi = function(group, options)
      vim.api.nvim_set_hl(0, group, options)
    end
  else
    ---@param group string
    ---@param options table
    hi = function(group, options)
      local opts = {}
      for k, v in pairs(options) do
        if k == 'fg' or k == 'bg' then
          opts['cterm' .. k] = v
        else
          opts[k] = v
        end
      end
      vim.api.nvim_set_hl(0, group, opts)
    end
  end

  local sign_col_bg = ''

  local error = c.red
  local hint = c.dim_0
  local info = c.br_blue
  local warn = c.orange

  hilink('Boolean', 'Constant')
  hilink('Character', 'Constant')
  hilink('Conditional', 'Statement')
  hilink('Debug', 'Special')
  hilink('Define', 'PreProc')
  hilink('ErrorMsg', 'Error')
  hilink('Exception', 'Statement')
  hilink('Float', 'Constant')
  hilink('FloatBorder', 'NormalFloat')
  hilink('Include', 'PreProc')
  hilink('Keyword', 'Statement')
  hilink('Label', 'Statement')
  hilink('Macro', 'PreProc')
  hilink('MatchParen', 'MatchBackground')
  hilink('Number', 'Constant')
  hilink('Operator', 'Statement')
  hilink('PreCondit', 'PreProc')
  hilink('QuickFixLine', 'Search')
  hilink('Repeat', 'Statement')
  hilink('SpecialChar', 'Special')
  hilink('SpecialComment', 'Special')
  hilink('StatusLineTerm', 'StatusLine')
  hilink('StatusLineTermNC', 'StatusLineNC')
  hilink('StorageClass', 'Type')
  hilink('String', 'Constant')
  hilink('Structure', 'Type')
  hilink('Tag', 'Special')
  hilink('Typedef', 'Type')
  hilink('lCursor', 'Cursor')

  hi('ColorColumn', { bg = c.bg_1 })
  hi('Comment', { fg = c.dim_0, italic = true })
  hi('Conceal', {})
  hi('Constant', { fg = c.cyan })
  hi('Cursor', { reverse = true })
  hi('CursorColumn', { bg = c.bg_1 })
  hi('CursorLine', { bg = c.bg_1 })
  hi('CursorLineNr', { fg = c.fg_1 })
  hi('Delimiter', { fg = c.fg_0, bold = true })
  hi('Directory', {})
  hi('EndOfBuffer', {})
  hi('Error', { fg = error, bold = true })
  hi('FoldColumn', {})
  hi('Folded', { bg = c.bg_1 })
  hi('Function', { fg = c.br_blue })
  hi('Identifier', { fg = c.violet })
  hi('Ignore', { fg = c.bg_2 })
  hi('IncSearch', { fg = c.orange, reverse = true })
  hi('LineNr', { fg = c.bg_2, bg = sign_col_bg })
  hi('ModeMsg', {})
  hi('MoreMsg', {})
  hi('NonText', {})
  hi('Normal', { fg = c.fg_0, bg = c.bg_0 })
  hi('NormalFloat', { bg = c.bg_0 })
  hi('NormalNC', { fg = c.dim_0, bg = c.bg_0 })
  hi('Pmenu', { fg = c.fg_0, bg = c.bg_1 })
  hi('PmenuSbar', { fg = c.bg_2 })
  hi('PmenuSel', { bg = c.bg_2 })
  hi('PmenuThumb', { bg = c.dim_0 })
  hi('PreProc', { fg = c.orange })
  hi('Question', {})
  hi('Search', { fg = c.yellow, reverse = true })
  hi('SignColumn', { bg = sign_col_bg })
  hi('Special', { fg = c.orange, bold = true })
  hi('SpecialKey', {})
  hi('SpellBad', { undercurl = true, sp = c.red })
  hi('SpellCap', { undercurl = true, sp = c.red })
  hi('SpellLocal', { undercurl = true, sp = c.yellow })
  hi('SpellRare', { undercurl = true, sp = c.cyan })
  hi('Statement', { fg = c.yellow })
  hi('StatusLine', { reverse = true })
  hi('StatusLineNC', { bg = c.bg_2 })
  hi('TabLine', { fg = c.dim_0, reverse = true })
  hi('TabLineFill', { fg = c.dim_0, reverse = true })
  hi('TabLineSel', { fg = c.fg_1, bg = c.bg_1, bold = true, reverse = true })
  hi('Terminal', {})
  hi('Title', { fg = c.orange, bold = true })
  hi('Todo', { fg = c.magenta, bold = true })
  hi('ToolbarButton', { reverse = true })
  hi('ToolbarLine', { bg = c.bg_2 })
  hi('Type', { fg = c.green })
  hi('Underlined', { fg = c.violet, underline = true })
  hi('VertSplit', { fg = c.dim_0, bg = c.bg_0 })
  hi('VimCommand', { fg = c.yellow })
  hi('Visual', { bg = c.bg_2 })
  hi('VisualNOS', {})
  hi('WarningMsg', {})
  hi('WildMenu', {})

  hi('DiagnosticError', { fg = error })
  hi('DiagnosticWarn', { fg = warn })
  hi('DiagnosticInfo', { fg = info })
  hi('DiagnosticHint', { fg = hint })
  hi('DiagnosticSignError', { fg = error, bg = sign_col_bg })
  hi('DiagnosticSignWarn', { fg = warn, bg = sign_col_bg })
  hi('DiagnosticSignInfo', { fg = info, bg = sign_col_bg })
  hi('DiagnosticSignHint', { fg = hint, bg = sign_col_bg })
  hi('DiagnosticUnderlineError', { undercurl = true, sp = error })
  hi('DiagnosticUnderlineWarn', { undercurl = true, sp = warn })
  hi('DiagnosticUnderlineInfo', { undercurl = true, sp = info })
  hi('DiagnosticUnderlineHint', { undercurl = true, sp = hint })
  hi('DiagnosticVirtualTextError', { fg = error, italic = true })
  hi('DiagnosticVirtualTextWawrn', { fg = warn, italic = true })
  hi('DiagnosticVirtualTextInfo', { fg = info, italic = true })
  hi('DiagnosticVirtualTextHint', { fg = hint, italic = true })
  hi('DiagnosticVirtualTextOk', { italic = true })

  hi('DiffAdd', { fg = c.green, bg = c.bg_1 })
  hi('DiffChange', { fg = c.yellow, bg = c.bg_1 })
  hi('DiffDelete', { fg = c.red, bg = c.bg_1 })
  hi('DiffText', { fg = c.bg_1, bg = c.yellow })

  hi('LspReferenceRead', { bg = c.bg_1 })
  hi('LspReferenceText', { bg = c.bg_1 })
  hi('LspReferenceWrite', { bg = c.bg_1 })

  hi('RubyDefine', { fg = c.fg_1, bold = true })

  hi('diffAdded', { fg = c.green })
  hi('diffRemoved', { fg = c.red })
  hi('diffOldFile', { fg = c.br_red })
  hi('diffNewFile', { fg = c.br_green })
  hi('diffFile', { fg = c.blue })

  hilink('TSConstBuiltin', 'Constant')
  hilink('TSConstMacro', 'Constant')
  hilink('TSFuncBuiltin', 'Function')
  hilink('TSConstructor', 'Function')
  hilink('@tag', 'Statement')
  hilink('@tag.delimiter', 'Delimiter')
  hilink('@tag.attribute', 'Type')
  hilink('@operator', 'Operator')
  hilink('@string', 'String')
  hilink('@variable', 'Identifier')
  hilink('@keyword', 'Keyword')

  hilink('typescriptBraces', 'Delimiter')
  hilink('typescriptParens', 'Delimiter')

  hilink('javascriptBraces', 'Delimiter')
  hilink('javascriptParens', 'Delimiter')

  hilink('markdownCodeDelimiter', 'Delimiter')
  hi('markdownCode', { fg = c.orange, bg = c.bg_1 })

  hi('StartifyHeader', { fg = c.green })
  hi('StartifyFile', { fg = c.blue })

  hi('DevIconBash', { fg = c.green })
  hi('DevIconBat', { fg = c.green })
  hi('DevIconJson', { fg = c.yellow })

  hi('GitSignsAdd', { fg = c.green, bg = sign_col_bg })
  hi('GitSignsChange', { fg = c.yellow, bg = sign_col_bg })
  hi('GitSignsDelete', { fg = c.red, bg = sign_col_bg })

  hilink('LspDiagnosticsDefaultHint', 'DiagnosticHint')
  hilink('LspDiagnosticsDefaultInformation', 'DiagnosticInfo')
  hilink('LspDiagnosticsDefaultWarning', 'DiagnosticWarn')
  hilink('LspDiagnosticsDefaultError', 'DiagnosticError')
  hilink('LspDiagnosticsSignHint', 'DiagnosticSignHint')
  hilink('LspDiagnosticsSignInformation', 'DiagnosticSignInfo')
  hilink('LspDiagnosticsSignWarning', 'DiagnosticSignWarn')
  hilink('LspDiagnosticsSignError', 'DiagnosticSignError')

  hi('NotifyBackground', { bg = c.bg_0 })
  hilink('NotifyDEBUGTitle', 'DiagnosticHint')
  hilink('NotifyDEBUGIcon', 'DiagnosticHint')
  hilink('NotifyINFOTitle', 'DiagnosticInfo')
  hilink('NotifyINFOIcon', 'DiagnosticInfo')
  hilink('NotifyWARNTitle', 'DiagnosticWarn')
  hilink('NotifyWARNIcon', 'DiagnosticWarn')
  hilink('NotifyERRORTitle', 'DiagnosticError')
  hilink('NotifyERRORIcon', 'DiagnosticError')

  hilink('NeoTreeFloatBorder', 'Normal')
end

local M = {}

---@return nil
function M.apply()
  local colors = M.load_colors()

  vim.g.colors_name = 'wezterm'

  if vim.go.termguicolors then
    ---@cast colors Palette
    if require('user.util.theme').is_dark(colors.bg_0) then
      vim.go.background = 'dark'
    else
      vim.go.background = 'light'
    end
  end

  apply_theme(colors)

  vim.api.nvim_exec_autocmds('ColorScheme', {})
end

---@return Palette | CtermPalette
function M.load_colors()
  if vim.go.termguicolors then
    local colors_file = os.getenv('HOME') .. '/.local/share/wezterm/colors.json'
    local ok, colors_text = pcall(vim.fn.readfile, colors_file)

    if not ok then
      return palettes.white
    else
      local scheme = vim.fn.json_decode(colors_text)
      ---@cast scheme table
      return to_selenized(scheme)
    end
  else
    return cterm_palette
  end
end

return M
