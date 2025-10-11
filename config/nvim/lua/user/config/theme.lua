-- vim.o.termguicolors = false
-- vim.cmd('hi CursorLine ctermbg=0')
-- vim.cmd('hi Comment ctermfg=7 cterm=italic')
-- vim.cmd('hi Delimiter ctermfg=7')
-- vim.cmd('hi Statement ctermfg=7')
-- vim.cmd('hi Constant ctermfg=5')
-- vim.cmd('hi String ctermfg=6')
-- vim.cmd('hi Function ctermfg=3')
-- vim.cmd('hi LineNr ctermfg=8')
-- vim.cmd('hi Visual ctermbg=0 ctermfg=NONE')
-- vim.cmd('hi MiniStatuslineModeNormal ctermfg=4 ctermbg=0')
-- vim.cmd('hi MiniStatuslineModeInsert ctermfg=2')
-- vim.cmd('hi MiniStatuslineModeCommand ctermfg=1')
-- vim.cmd('hi MiniStatuslineModeVisual ctermfg=5')
-- vim.cmd('hi MiniStatuslineDevInfo cterm=NONE ctermfg=8 ctermbg=15')
-- vim.cmd('hi MiniStatuslineFilename cterm=NONE ctermfg=0 ctermbg=7')
-- vim.cmd('hi WinBar cterm=NONE ctermbg=0')

---@alias Palette {
---  bg_0: string,
---  bg_1: string,
---  bg_2: string,
---  dim_0: string,
---  fg_0: string,
---  fg_1: string,
---  red: string,
---  green: string,
---  yellow: string,
---  blue: string,
---  magenta: string,
---  cyan: string,
---  br_red: string,
---  br_green: string,
---  br_yellow: string,
---  br_blue: string,
---  br_magenta: string,
---  br_cyan: string,
---  orange: string,
---  br_orange: string,
---  violet: string,
---  br_violet: string }

---@alias CtermPalette {
---  bg_0: number,
---  bg_1: number,
---  bg_2: number,
---  dim_0: number,
---  fg_0: number,
---  fg_1: number,
---  red: number,
---  green: number,
---  yellow: number,
---  blue: number,
---  magenta: number,
---  cyan: number,
---  br_red: number,
---  br_green: number,
---  br_yellow: number,
---  br_blue: number,
---  br_magenta: number,
---  br_cyan: number,
---  orange: number,
---  br_orange: number,
---  violet: number,
---  br_violet: number }

local ansi_dark = {
  '#252525',
  '#ed4a46',
  '#70b433',
  '#dbb32d',
  '#368aeb',
  '#eb6eb7',
  '#3fc5b7',
  '#777777',
  '#3b3b3b',
  '#ff5e56',
  '#83c746',
  '#efc541',
  '#4f9cfe',
  '#ff81ca',
  '#56d8c9',
  '#dedede',
}

local ansi_light = {
  '#ebebeb',
  '#d6000c',
  '#1d9700',
  '#c49700',
  '#0064e4',
  '#dd0f9d',
  '#00ad9c',
  '#878787',
  '#cdcdcd',
  '#bf0000',
  '#008400',
  '#af8500',
  '#0054cf',
  '#c7008b',
  '#009a8a',
  '#282828',
}

---@type Palette
local dark_palette = {
  bg_0 = '#181818',
  bg_1 = ansi_dark[1],
  bg_2 = ansi_dark[9],
  dim_0 = ansi_dark[8],
  fg_0 = '#b9b9b9',
  fg_1 = ansi_dark[16],
  red = ansi_dark[2],
  green = ansi_dark[3],
  yellow = ansi_dark[4],
  blue = ansi_dark[5],
  magenta = ansi_dark[6],
  cyan = ansi_dark[7],
  br_red = ansi_dark[10],
  br_green = ansi_dark[11],
  br_yellow = ansi_dark[12],
  br_blue = ansi_dark[13],
  br_magenta = ansi_dark[14],
  br_cyan = ansi_dark[15],
  orange = '#e67f43',
  violet = '#a580e2',
  br_orange = '#fa9153',
  br_violet = '#b891f5',
}

---@type Palette
local light_palette = {
  bg_0 = '#ffffff',
  bg_1 = ansi_light[1],
  bg_2 = ansi_light[9],
  dim_0 = ansi_light[8],
  fg_0 = '#575757',
  fg_1 = ansi_light[16],
  red = ansi_light[2],
  green = ansi_light[3],
  yellow = ansi_light[4],
  blue = ansi_light[5],
  magenta = ansi_light[6],
  cyan = ansi_light[7],
  br_red = ansi_light[10],
  br_green = ansi_light[11],
  br_yellow = ansi_light[12],
  br_blue = ansi_light[13],
  br_magenta = ansi_light[14],
  br_cyan = ansi_light[15],
  orange = '#d04a00',
  violet = '#7f51d6',
  br_orange = '#ba3700',
  br_violet = '#6b40c3',
}

---@type CtermPalette
local cterm_palette = {
  bg_0 = 0,
  bg_1 = 0,
  bg_2 = 8,
  dim_0 = 7,
  fg_0 = 15,
  fg_1 = 15,
  red = 1,
  green = 2,
  yellow = 3,
  blue = 4,
  magenta = 5,
  cyan = 6,
  br_red = 9,
  br_green = 10,
  br_yellow = 11,
  br_blue = 12,
  br_magenta = 13,
  br_cyan = 14,
  orange = 208,
  violet = 92,
  br_orange = 214,
  br_violet = 128,
}

local home = vim.uv.os_homedir()
local themefile = home .. '/.local/share/theme'

-- Update the `background` option based on the theme file
local function update_background()
  if vim.fn.filereadable(themefile) == 1 then
    local theme = vim.fn.readfile(themefile)[1]
    if theme then
      vim.o.background = theme
    end
  end
end

---@return Palette | CtermPalette
local function get_palette()
  if vim.go.termguicolors then
    if vim.go.background == 'light' then
      return light_palette
    end
    return dark_palette
  end
  return cterm_palette
end

-- A convenience function for linking highlight groups
---@param group string
---@param other_group string
local function hilink(group, other_group)
  vim.api.nvim_set_hl(0, group, { link = other_group })
end

-- A convenience function for setting highlight groups
---@param group string
---@param options table
local function hi(group, options)
  local opts = {}
  for k, v in pairs(options) do
    if k == 'fg' or k == 'bg' then
      if v[1] == '#' then
        opts[k] = v
      else
        opts['cterm' .. k] = cterm_palette[v]
        opts[k] = get_palette()[v]
      end
    elseif k == 'sp' then
      if v[1] ~= '#' then
        v = get_palette()[v]
      end
      opts[k] = v
    else
      opts[k] = v
    end
  end
  vim.api.nvim_set_hl(0, group, opts)
end

-- Apply a the proper theme for the current background color
---@return nil
local function apply_theme()
  -- Note: setting the cursor color using the Cursor group in guicursor will
  -- break WezTerm's ability to dynamically update the theme in a pane.

  local sign_col_bg = ''
  local error = 'red'
  local hint = 'dim_0'
  local info = 'br_blue'
  local warn = 'orange'

  hilink('Boolean', 'Constant')
  hilink('Character', 'Constant')
  hilink('Conditional', 'Statement')
  hilink('Debug', 'Special')
  hilink('Define', 'PreProc')
  hilink('ErrorMsg', 'Error')
  hilink('Exception', 'Statement')
  hilink('Float', 'Constant')
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

  hi('ColorColumn', { bg = 'bg_1' })
  hi('Comment', { fg = 'dim_0', italic = true })
  hi('Conceal', {})
  hi('Constant', { fg = 'cyan' })
  hi('Cursor', { reverse = true })
  hi('CursorColumn', { bg = 'bg_1' })
  hi('CursorLine', { bg = 'bg_1' })
  hi('CursorLineNr', { fg = 'fg_1' })
  hi('Delimiter', { fg = 'fg_0', bold = true })
  hi('Directory', {})
  hi('EndOfBuffer', {})
  hi('Error', { fg = error, bold = true })
  hi('FloatBorder', { fg = 'bg_2' })
  hi('FoldColumn', {})
  hi('Folded', { bg = 'bg_1' })
  hi('Function', { fg = 'br_blue' })
  hi('Identifier', { fg = 'violet' })
  hi('Ignore', { fg = 'bg_2' })
  hi('IncSearch', { fg = 'orange', reverse = true })
  hi('LineNr', { fg = 'bg_2', bg = sign_col_bg })
  hi('ModeMsg', {})
  hi('MoreMsg', {})
  hi('NonText', {})
  hi('Normal', { fg = 'fg_0' })
  hi('NormalNC', { fg = 'dim_0' })
  hi('Pmenu', { fg = 'fg_0' })
  hi('PmenuSbar', { fg = 'bg_2' })
  hi('PmenuSel', { bg = 'bg_2' })
  hi('PmenuThumb', { bg = 'dim_0' })
  hi('PreProc', { fg = 'orange' })
  hi('Question', {})
  hi('Search', { fg = 'yellow', reverse = true })
  hi('SignColumn', { bg = sign_col_bg })
  hi('Special', { fg = 'orange', bold = true })
  hi('SpecialKey', {})
  hi('SpellBad', { undercurl = true, sp = 'red' })
  hi('SpellCap', { undercurl = true, sp = 'red' })
  hi('SpellLocal', { undercurl = true, sp = 'yellow' })
  hi('SpellRare', { undercurl = true, sp = 'cyan' })
  hi('Statement', { fg = 'yellow' })
  hi('TabLine', { fg = 'dim_0', reverse = true })
  hi('TabLineFill', { fg = 'dim_0', reverse = true })
  hi('TabLineSel', { fg = 'fg_1', bg = 'bg_1', bold = true, reverse = true })
  hi('Terminal', {})
  hi('Title', { fg = 'blue', bold = true })
  hi('Todo', { fg = 'magenta', bold = true })
  hi('ToolbarButton', { reverse = true })
  hi('ToolbarLine', { bg = 'bg_2' })
  hi('Type', { fg = 'green' })
  hi('Underlined', { fg = 'violet', underline = true })
  hi('VertSplit', { fg = 'dim_0' })
  hi('VimCommand', { fg = 'yellow' })
  hi('Visual', { bg = 'bg_1' })
  hi('VisualNOS', {})
  hi('WarningMsg', {})
  hi('WildMenu', {})
  hi('WinBar', { bg = 'bg_1', fg = 'fg_0' })

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
  hi('DiagnosticVirtualTextWarn', { fg = warn, italic = true })
  hi('DiagnosticVirtualTextInfo', { fg = info, italic = true })
  hi('DiagnosticVirtualTextHint', { fg = hint, italic = true })
  hi('DiagnosticVirtualTextOk', { italic = true })

  hi('DiffAdd', { fg = 'green', bg = 'bg_1' })
  hi('DiffChange', { fg = 'yellow', bg = 'bg_1' })
  hi('DiffDelete', { fg = 'red', bg = 'bg_1' })
  hi('DiffText', { fg = 'bg_1', bg = 'yellow' })

  hi('LspReferenceRead', { bg = 'bg_1' })
  hi('LspReferenceText', { bg = 'bg_1' })
  hi('LspReferenceWrite', { bg = 'bg_1' })

  hi('RubyDefine', { fg = 'fg_1', bold = true })

  hi('diffAdded', { fg = 'green' })
  hi('diffRemoved', { fg = 'red' })
  hi('diffOldFile', { fg = 'br_red' })
  hi('diffNewFile', { fg = 'br_green' })
  hi('diffFile', { fg = 'blue' })
  hi('diffLine', { fg = 'yellow' })

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
  hi('@markup.link.label', { fg = 'blue' })
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
  hi('markdownCode', { fg = 'orange', bg = 'bg_1' })

  hi('StartifyHeader', { fg = 'green' })
  hi('StartifyFile', { fg = 'blue' })

  hi('DevIconBash', { fg = 'green' })
  hi('DevIconBat', { fg = 'green' })
  hi('DevIconJson', { fg = 'yellow' })

  hi('GitSignsAdd', { fg = 'green', bg = sign_col_bg })
  hi('GitSignsChange', { fg = 'yellow', bg = sign_col_bg })
  hi('GitSignsDelete', { fg = 'red', bg = sign_col_bg })

  hi('MiniStatuslineModeNormal', { fg = 'bg_0', bg = 'blue' })
  hi('MiniStatuslineModeInsert', { fg = 'bg_0', bg = 'green' })
  hi('MiniStatuslineModeCommand', { fg = 'bg_0', bg = 'orange' })
  hi('MiniStatuslineModeVisual', { fg = 'bg_0', bg = 'violet' })
  hi('MiniStatuslineDevInfo', { fg = 'fg_0', bg = 'bg_2' })
  hi('MiniStatuslineFilename', { fg = 'fg_0', bg = 'bg_1' })
  hi('MiniStatuslineError', { fg = error, bg = 'bg_2' })
  hi('MiniStatuslineWarning', { fg = warn, bg = 'bg_2' })
  hi('MiniStatuslineInfo', { fg = info, bg = 'bg_2' })
  hi('MiniStatuslineHint', { fg = hint, bg = 'bg_2' })
  hi('MiniStarterCurrent', { bg = 'bg_2' })

  hi('MiniStarterSection', { fg = 'blue' })
  hi('MiniStarterItemPrefix', { fg = 'yellow' })
  hi('MiniStarterCurrent', { bg = nil })

  hi('MiniJump2dSpot', { bg = 'bg_1', fg = 'fg_1', bold = true })

  hi('MiniCursorWord', { bg = 'bg_1', underline = false })

  hi('MiniPickMatchRanges', { fg = 'magenta' })

  hi('MiniIndentScopeSymbol', { fg = 'bg_2' })

  hi('MiniHiPatternsTodo', { fg = 'magenta', bold = true })

  hilink('LspDiagnosticsDefaultHint', 'DiagnosticHint')
  hilink('LspDiagnosticsDefaultInformation', 'DiagnosticInfo')
  hilink('LspDiagnosticsDefaultWarning', 'DiagnosticWarn')
  hilink('LspDiagnosticsDefaultError', 'DiagnosticError')
  hilink('LspDiagnosticsSignHint', 'DiagnosticSignHint')
  hilink('LspDiagnosticsSignInformation', 'DiagnosticSignInfo')
  hilink('LspDiagnosticsSignWarning', 'DiagnosticSignWarn')
  hilink('LspDiagnosticsSignError', 'DiagnosticSignError')

  hi('NotifyBackground', { bg = 'bg_0' })
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

  hi('SnacksIndent', { fg = 'dim_0' })
  hi('SnacksPickerTree', { fg = 'dim_0' })
  hi('SnacksPickerTitle', { fg = 'br_blue', bg = 'bg_0' })

  hi('DropBarMenuNormalFloat', { fg = 'fg_1', bg = 'bg_1' })
  hi('DropBarMenuHoverEntry', { fg = 'fg_1', bg = 'bg_2' })

  hilink('BlinkCmpGhostText', 'Comment')

  -- Ensure RenderMarkdownCode doesn't get linked to ColorColumn, then set its
  -- background to the normal background.
  hilink('RenderMarkdownCode', 'NONE')
  hi('RenderMarkdownCode', { bg = 'bg_0' })

  hilink('RenderMarkdownH1Bg', 'NONE')
  hilink('RenderMarkdownH2Bg', 'NONE')
  hilink('RenderMarkdownH3Bg', 'NONE')
  hilink('RenderMarkdownH4Bg', 'NONE')
  hilink('RenderMarkdownH5Bg', 'NONE')
  hilink('RenderMarkdownH6Bg', 'NONE')

  -- notify listeners that the colorscheme has been set
  vim.api.nvim_exec_autocmds('ColorScheme', {})

  -- Check for a theme file. If it exists, it will be updated by a background
  -- process when the system theme changes.
  if vim.fn.filereadable(themefile) == 1 then
    local w = vim.uv.new_fs_event()
    if w ~= nil then
      ---@type function
      local watch_file

      local function on_change()
        update_background()
        w:stop()
        watch_file(themefile)
      end

      watch_file = function()
        w:start(themefile, {}, vim.schedule_wrap(on_change))
      end

      watch_file()
    else
      vim.notify('Unable to read theme file ' .. themefile, vim.log.levels.WARN)
    end
  end
end

-- Always assume the terminal supports RGB colors, even if it's not detected
-- (e.g., Windows Terminal).
vim.o.termguicolors = true

-- initially clear the Normal group to prevent a flash of an incorrect
-- background
vim.api.nvim_set_hl(0, 'Normal', {})

-- load the theme if the TUI color handling setup changes
vim.api.nvim_create_autocmd('OptionSet', {
  pattern = { 'background' },
  callback = function()
    apply_theme()
  end,
})

if vim.g.neovide or vim.fn.has('win32') then
  update_background()
  apply_theme()
end
