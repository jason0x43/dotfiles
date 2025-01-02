local os = require('os')

---@alias Palette
---| { bg_0: string, bg_1: string, bg_2: string, dim_0: string, fg_0: string, fg_1: string, red: string, green: string, yellow: string, blue: string, magenta: string, cyan: string, br_red: string, br_green: string, br_yellow: string, br_blue: string, br_magenta: string, br_cyan: string, orange: string, br_orange: string, violet: string, br_violet: string }
---@alias CtermPalette
---| { bg_0: number | nil, bg_1: number | nil, bg_2: number | nil, dim_0: number | nil, fg_0: number | nil, fg_1: number | nil, red: number | nil, green: number | nil, yellow: number | nil, blue: number | nil, magenta: number | nil, cyan: number | nil, br_red: number | nil, br_green: number | nil, br_yellow: number | nil, br_blue: number | nil, br_magenta: number | nil, br_cyan: number | nil, orange: number | nil, br_orange: number | nil, violet: number | nil, br_violet: number | nil }

-- Default color palettes in the Selenized format
---@type { [string]: Palette }
local palettes = {
  dark = {
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
  light = {
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

local cterm_palette = {
  bg_0 = 0,
  fg_0 = 15,
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

---@return Palette | CtermPalette
local function load_colors()
  if vim.go.termguicolors then
    if vim.go.background == 'light' then
      return palettes.light
    end

    return palettes.dark
  end

  return cterm_palette
end

-- A convenience function for linking highlight groups
---@param group string
---@param other_group string
local function hilink(group, other_group)
  vim.api.nvim_set_hl(0, group, { link = other_group })
end

local M = {
  load_colors = load_colors,
}

-- Apply a theme in the Selenized format
---@return nil
local function apply_theme()
  local c = load_colors()

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
  hilink('NormalFloat', 'Normal')
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
  hi('Normal', { fg = c.fg_0 })
  hi('NormalNC', { fg = c.dim_0 })
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
  hi('TabLine', { fg = c.dim_0, reverse = true })
  hi('TabLineFill', { fg = c.dim_0, reverse = true })
  hi('TabLineSel', { fg = c.fg_1, bg = c.bg_1, bold = true, reverse = true })
  hi('Terminal', {})
  hi('Title', { fg = c.blue, bold = true })
  hi('Todo', { fg = c.magenta, bold = true })
  hi('ToolbarButton', { reverse = true })
  hi('ToolbarLine', { bg = c.bg_2 })
  hi('Type', { fg = c.green })
  hi('Underlined', { fg = c.violet, underline = true })
  hi('VertSplit', { fg = c.dim_0 })
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
  hi('diffLine', { fg = c.yellow })

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

  hi('@markup.strong', { bold = true })
  hi('@markup.emphasis', { bold = true, italic = true })
  hi('@markup.italic', { italic = true })
  hi('@markup.underline', { underline = true })
  hi('@markup.strike', { strikethrough = true })
  hi('@markup.link.label', { fg = c.blue })
  hilink('@markup.link', 'Underlined')
  hilink('@markup.list', 'Delimiter')
  hilink('@markup.raw', 'String')
  hilink('@markup.heading', 'Title')

  hilink('@diff.plus', 'diffAdded')
  hilink('@diff.minus', 'diffRemoved')
  hilink('@attribute', 'Type')

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

  hi('MiniStatuslineModeNormal', { fg = c.bg_0, bg = c.blue })
  hi('MiniStatuslineModeInsert', { fg = c.bg_0, bg = c.green })
  hi('MiniStatuslineModeCommand', { fg = c.bg_0, bg = c.orange })
  hi('MiniStatuslineModeVisual', { fg = c.bg_0, bg = c.violet })
  hi('MiniStatuslineDevInfo', { fg = c.fg_0, bg = c.bg_2 })
  hi('MiniStatuslineFilename', { fg = c.fg_0, bg = c.bg_1 })
  hi('MiniStatuslineError', { fg = error, bg = c.bg_2 })
  hi('MiniStatuslineWarning', { fg = warn, bg = c.bg_2 })
  hi('MiniStatuslineInfo', { fg = info, bg = c.bg_2 })
  hi('MiniStatuslineHint', { fg = hint, bg = c.bg_2 })
  hi('MiniStarterCurrent', { bg = c.bg_2 })

  hi('MiniJump2dSpot', { bg = c.bg_1, fg = c.fg_1, bold = true })

  hi('MiniCursorWord', { bg = c.bg_1, underline = false })

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

  hilink('NavbuddyArray', 'Identifier')
  hilink('NavbuddyBoolean', 'Boolean')
  hilink('NavbuddyClass', 'Type')
  hilink('NavbuddyConstant', 'Constant')
  hilink('NavbuddyConstructor', 'Function')
  hilink('NavbuddyFile', 'Special')
  hilink('NavbuddyFunction', 'Function')
  hilink('NavbuddyInterface', 'Type')
  hilink('NavbuddyMethod', 'Function')
  hilink('NavbuddyNull', 'Special')
  hilink('NavbuddyNumber', 'Number')
  hilink('NavbuddyObject', 'Identifier')
  hilink('NavbuddyOperator', 'Operator')
  hilink('NavbuddyString', 'String')
  hilink('NavbuddyStruct', 'Structure')
  hilink('NavbuddyVariable', '@variable')

  hilink('SnacksDashboardDesc', 'Normal')
  hilink('SnacksDashboardTitle', 'Title')

  -- notify listeners that the colorscheme has been set
  vim.g.colors_name = 'wezterm'
  vim.api.nvim_exec_autocmds('ColorScheme', {})

  -- Check for a theme file. If it exists, it will be updated by a background
  -- process when the system theme changes.
  local home = os.getenv('HOME')
  local themefile = home .. '/.local/share/theme'
  if vim.fn.filereadable(themefile) == 1 then
    local w = vim.uv.new_fs_event()
    if w ~= nil then
      local function watch_file(_) end

      local function on_change()
        local theme = vim.fn.readfile(themefile)[1]
        if theme then
          vim.go.background = theme
        end
        w:stop()
        watch_file(themefile)
      end

      watch_file = function()
        w:start(themefile, {}, vim.schedule_wrap(on_change))
      end

      watch_file()
    end
  end
end

---@return nil
function M.setup()
  -- initially clear the Normal group to prevent a flash of an incorrect
  -- background
  vim.api.nvim_set_hl(0, 'Normal', {})

  -- load the theme if the TUI color handling setup changes
  vim.api.nvim_create_autocmd('OptionSet', {
    pattern = { 'background', 'termguicolors' },
    callback = function()
      apply_theme()
    end,
  })
end

return M
