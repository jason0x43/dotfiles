local color_shift = require('user.util.theme').shift

local colors = {
  latte = {
    rosewater = '#dc8a78',
    flamingo = '#DD7878',
    pink = '#ea76cb',
    mauve = '#8839EF',
    red = '#D20F39',
    maroon = '#E64553',
    peach = '#FE640B',
    yellow = '#df8e1d',
    green = '#40A02B',
    teal = '#179299',
    sky = '#04A5E5',
    sapphire = '#209FB5',
    blue = '#1e66f5',
    lavender = '#7287FD',
    text = '#4C4F69',
    subtext1 = '#5C5F77',
    subtext0 = '#6C6F85',
    overlay2 = '#7C7F93',
    overlay1 = '#8C8FA1',
    overlay0 = '#9CA0B0',
    surface2 = '#ACB0BE',
    surface1 = '#BCC0CC',
    surface0 = '#CCD0DA',
    base = '#EFF1F5',
    mantle = '#E6E9EF',
    crust = '#DCE0E8',
  },
  frappe = {
    rosewater = '#F2D5CF',
    flamingo = '#EEBEBE',
    pink = '#F4B8E4',
    mauve = '#CA9EE6',
    red = '#E78284',
    maroon = '#EA999C',
    peach = '#EF9F76',
    yellow = '#E5C890',
    green = '#A6D189',
    teal = '#81C8BE',
    sky = '#99D1DB',
    sapphire = '#85C1DC',
    blue = '#8CAAEE',
    lavender = '#BABBF1',
    text = '#c6d0f5',
    subtext1 = '#b5bfe2',
    subtext0 = '#a5adce',
    overlay2 = '#949cbb',
    overlay1 = '#838ba7',
    overlay0 = '#737994',
    surface2 = '#626880',
    surface1 = '#51576d',
    surface0 = '#414559',
    base = '#303446',
    mantle = '#292C3C',
    crust = '#232634',
  },
  macchiato = {
    rosewater = '#F4DBD6',
    flamingo = '#F0C6C6',
    pink = '#F5BDE6',
    mauve = '#C6A0F6',
    red = '#ED8796',
    maroon = '#EE99A0',
    peach = '#F5A97F',
    yellow = '#EED49F',
    green = '#A6DA95',
    teal = '#8BD5CA',
    sky = '#91D7E3',
    sapphire = '#7DC4E4',
    blue = '#8AADF4',
    lavender = '#B7BDF8',
    text = '#CAD3F5',
    subtext1 = '#B8C0E0',
    subtext0 = '#A5ADCB',
    overlay2 = '#939AB7',
    overlay1 = '#8087A2',
    overlay0 = '#6E738D',
    surface2 = '#5B6078',
    surface1 = '#494D64',
    surface0 = '#363A4F',
    base = '#24273A',
    mantle = '#1E2030',
    crust = '#181926',
  },
  mocha = {
    rosewater = '#F5E0DC',
    flamingo = '#F2CDCD',
    pink = '#F5C2E7',
    mauve = '#CBA6F7',
    red = '#F38BA8',
    maroon = '#EBA0AC',
    peach = '#FAB387',
    yellow = '#F9E2AF',
    green = '#A6E3A1',
    teal = '#94E2D5',
    sky = '#89DCEB',
    sapphire = '#74C7EC',
    blue = '#89B4FA',
    lavender = '#B4BEFE',
    text = '#CDD6F4',
    subtext1 = '#BAC2DE',
    subtext0 = '#A6ADC8',
    overlay2 = '#9399B2',
    overlay1 = '#7F849C',
    overlay0 = '#6C7086',
    surface2 = '#585B70',
    surface1 = '#45475A',
    surface0 = '#313244',
    base = '#1E1E2E',
    mantle = '#181825',
    crust = '#11111B',
  },
}

local M = {}

function M.apply(variant)
  local C = colors[variant]

  local hi = vim.api.nvim_set_hl
	local util = require('user.util.theme')

	if util.is_dark(C.base) then
		vim.go.background = 'dark'
	else
		vim.go.background = 'light'
	end

  local shift = function(color, amount)
    if variant ~= 'latte' then
      amount = -amount
    end
    return color_shift(color, amount)
  end

  local choose = function(color, latte_color)
    if variant == 'latte' then
      return latte_color
    end
    return color
  end

  hi(
    0,
    'CursorLine',
    { bg = choose(shift(C.mantle, 0.70), shift(C.surface0, 0.64)) }
  )
  hi(0, 'Bold', { bold = true })
  hi(0, 'Boolean', { fg = C.peach })
  hi(0, 'Character', { fg = C.teal })
  hi(0, 'ColorColumn', { bg = C.surface0 })
  hi(0, 'Comment', { fg = C.surface2, italic = true })
  hi(0, 'Conceal', { fg = C.overlay1 })
  hi(0, 'Conditional', { fg = C.mauve, italic = true })
  hi(0, 'Constant', { fg = C.peach })
  hi(0, 'CurSearch', { bg = C.red, fg = C.mantle })
  hi(0, 'Cursor', { fg = C.base, bg = C.text })
  hi(0, 'CursorColumn', { bg = C.mantle })
  hi(0, 'CursorIM', { fg = C.base, bg = C.text })
  hi(0, 'CursorLineNr', { fg = C.lavender })
  hi(0, 'Debug', { link = 'Special' })
  hi(0, 'Define', { link = 'PreProc' })
  hi(0, 'Delimiter', { link = 'Special' })
  hi(0, 'DiffAdd', { bg = shift(C.green, -0.18) })
  hi(0, 'DiffChange', { bg = shift(C.blue, -0.07) })
  hi(0, 'DiffDelete', { bg = shift(C.red, -0.18) })
  hi(0, 'DiffText', { bg = shift(C.blue, -0.18) })
  hi(0, 'Directory', { fg = C.blue })
  hi(0, 'EndOfBuffer', { fg = C.base })
  hi(0, 'Error', { fg = C.red })
  hi(0, 'ErrorMsg', { fg = C.red, bold = true, italic = true })
  hi(0, 'Float', { fg = C.peach })
  hi(0, 'FloatBorder', { fg = C.blue })
  hi(0, 'FoldColumn', { fg = C.overlay0 })
  hi(0, 'Folded', { fg = C.blue, bg = C.surface1 })
  hi(0, 'Function', { fg = C.blue })
  hi(0, 'Identifier', { fg = C.flamingo })
  hi(0, 'Ignore', {})
  hi(0, 'IncSearch', { bg = shift(C.sky, -0.90), fg = C.mantle })
  hi(0, 'Include', { fg = C.mauve })
  hi(0, 'Italic', { italic = true })
  hi(0, 'Keyword', { fg = C.mauve })
  hi(0, 'Label', { fg = C.sapphire })
  hi(0, 'LineNr', { fg = C.surface1 })
  hi(0, 'Macro', { fg = C.mauve })
  hi(0, 'MatchParen', { fg = C.peach, bold = true })
  hi(0, 'ModeMsg', { fg = C.text, bold = true })
  hi(0, 'MoreMsg', { fg = C.blue })
  hi(0, 'MsgArea', { fg = C.text })
  hi(0, 'MsgSeparator', {})
  hi(0, 'NonText', { fg = C.overlay0 })
  hi(0, 'Normal', { fg = C.text, bg = C.base })
  hi(0, 'NormalFloat', { fg = C.text, bg = C.mantle })
  hi(0, 'NormalNC', { fg = C.text })
  hi(0, 'NormalSB', { fg = C.text, bg = C.crust })
  hi(0, 'Number', { fg = C.peach })
  hi(0, 'Operator', { fg = C.sky })
  hi(0, 'Pmenu', { bg = shift(C.surface0, 0.8), fg = C.overlay2 })
  hi(0, 'PmenuSbar', { bg = C.surface1 })
  hi(0, 'PmenuSel', { fg = C.text, bg = C.surface1, bold = true })
  hi(0, 'PmenuThumb', { bg = C.overlay0 })
  hi(0, 'PreCondit', { link = 'PreProc' })
  hi(0, 'PreProc', { fg = C.pink })
  hi(0, 'Question', { fg = C.blue })
  hi(0, 'QuickFixLine', { bg = C.surface1, bold = true })
  hi(0, 'Repeat', { fg = C.mauve })
  hi(0, 'Search', { bg = shift(C.sky, 0.30), fg = C.text })
  hi(0, 'SignColumn', { fg = C.surface1 })
  hi(0, 'SignColumnSB', { bg = C.crust, fg = C.surface1 })
  hi(0, 'Special', { fg = C.pink, bold = true })
  hi(0, 'SpecialChar', { link = 'Special' })
  hi(0, 'SpecialComment', { link = 'Special' })
  hi(0, 'SpecialKey', { fg = C.text })
  hi(0, 'SpellBad', { sp = C.red, undercurl = true })
  hi(0, 'SpellCap', { sp = C.yellow, undercurl = true })
  hi(0, 'SpellLocal', { sp = C.blue, undercurl = true })
  hi(0, 'SpellRare', { sp = C.green, undercurl = true })
  hi(0, 'Statement', { fg = C.mauve })
  hi(0, 'StatusLine', { fg = C.text })
  hi(0, 'StatusLineNC', { fg = C.surface1 })
  hi(0, 'StorageClass', { fg = C.yellow })
  hi(0, 'String', { fg = C.green })
  hi(0, 'Structure', { fg = C.yellow })
  hi(0, 'Substitute', { bg = C.surface1, fg = choose(C.pink, C.red) })
  hi(0, 'TabLine', { bg = C.mantle, fg = C.surface1 })
  hi(0, 'TabLineFill', { bg = C.black })
  hi(0, 'TabLineSel', { fg = C.green, bg = C.surface1 })
  hi(0, 'Tag', { link = 'Special' })
  hi(0, 'Title', { fg = C.blue, bold = true })
  hi(0, 'Todo', { bg = C.yellow, fg = C.base, bold = true })
  hi(0, 'Type', { fg = C.yellow })
  hi(0, 'Typedef', { link = 'Type' })
  hi(0, 'Underlined', { underline = true })
  hi(0, 'VertSplit', { fg = C.crust })
  hi(0, 'Visual', { bg = C.surface1, bold = true })
  hi(0, 'VisualNOS', { bg = C.surface1, bold = true })
  hi(0, 'WarningMsg', { fg = C.yellow })
  hi(0, 'Whitespace', { fg = C.surface1 })
  hi(0, 'WildMenu', { bg = C.overlay0 })
  hi(0, 'WinBar', { fg = C.rosewater })
  hi(0, 'debugBreakpoint', { bg = C.base, fg = C.overlay0 })
  hi(0, 'debugPC', {})
  hi(0, 'lCursor', { fg = C.base, bg = C.text })

  -- quickfix
  hi(0, 'qfFileName', { fg = C.blue })
  hi(0, 'qfLineNr', { fg = C.yellow })

  -- markdown code sections
  hi(0, 'htmlH1', { fg = C.pink, bold = true })
  hi(0, 'htmlH2', { fg = C.blue, bold = true })
  hi(0, 'mkdCode', { bg = C.terminal_black, fg = C.text })
  hi(0, 'mkdCodeDelimiter', { bg = C.base, fg = C.text })
  hi(0, 'mkdCodeEnd', { fg = C.flamingo, bold = true })
  hi(0, 'mkdCodeStart', { fg = C.flamingo, bold = true })
  hi(0, 'mkdHeading', { fg = C.peach, bold = true })
  hi(0, 'mkdLink', { fg = C.blue, underline = true })

  -- illuminate
  hi(0, 'illuminatedCurWord', { bg = C.surface1 })
  hi(0, 'illuminatedWord', { bg = C.surface1 })

  -- diff
  hi(0, 'diffAdded', { fg = C.green })
  hi(0, 'diffChanged', { fg = C.blue })
  hi(0, 'diffFile', { fg = C.blue })
  hi(0, 'diffIndexLine', { fg = C.teal })
  hi(0, 'diffLine', { fg = C.overlay0 })
  hi(0, 'diffNewFile', { fg = C.peach })
  hi(0, 'diffOldFile', { fg = C.yellow })
  hi(0, 'diffRemoved', { fg = C.red })

  -- neovim health check
  hi(0, 'healthError', { fg = C.red })
  hi(0, 'healthSuccess', { fg = C.teal })
  hi(0, 'healthWarning', { fg = C.yellow })

  -- glyph-palette
  hi(0, 'GlyphPalette1', { fg = C.red })
  hi(0, 'GlyphPalette2', { fg = C.teal })
  hi(0, 'GlyphPalette3', { fg = C.yellow })
  hi(0, 'GlyphPalette4', { fg = C.blue })
  hi(0, 'GlyphPalette6', { fg = C.teal })
  hi(0, 'GlyphPalette7', { fg = C.text })
  hi(0, 'GlyphPalette9', { fg = C.red })

  -- treesitter
  hi(0, '@comment', { link = 'Comment' })
  hi(0, '@error', { link = 'Error' })
  hi(0, '@preproc', { link = 'PreProc' })
  hi(0, '@define', { link = 'Define' })
  hi(0, '@operator', { link = 'Operator' })

  -- Punctuation
  hi(0, '@punctuation.delimiter', { fg = C.overlay2 })
  hi(0, '@punctuation.bracket', { fg = C.overlay2 })
  hi(0, '@punctuation.special', { fg = C.sky, bold = true })

  -- Literals
  hi(0, '@string', { link = 'String' })
  hi(0, '@string.regex', { fg = C.peach })
  hi(0, '@string.escape', { fg = C.pink })
  hi(0, '@string.special', { fg = C.blue })
  hi(0, '@character', { link = 'Character' })
  hi(0, '@character.special', { link = 'SpecialChar' })
  hi(0, '@boolean', { link = 'Boolean' })
  hi(0, '@number', { link = 'Number' })
  hi(0, '@float', { link = 'Number' })

  -- Functions
  hi(0, '@function', { link = 'Function' })
  hi(0, '@function.builtin', { fg = C.peach })
  hi(0, '@function.call', { link = '@function' })
  hi(0, '@function.macro', { fg = C.teal })
  hi(0, '@method', { fg = C.peach })
  hi(0, '@method.call', { link = '@method' })
  hi(0, '@constructor', { fg = C.sapphire })
  hi(0, '@parameter', { fg = C.maroon, italic = true })

  -- Keywords
  hi(0, '@keyword', { link = 'Keyword' })
  hi(0, '@keyword.function', { fg = C.mauve })
  hi(0, '@keyword.operator', { fg = C.mauve, bold = true })
  hi(0, '@keyword.return', { fg = C.mauve })
  hi(0, '@conditional', { link = 'Conditional' })
  hi(0, '@repeat', { link = 'Repeat' })

  -- Debugging
  hi(0, '@label', { link = 'Label' })
  hi(0, '@include', { link = 'Include' })
  hi(0, '@exception', { fg = C.mauve })

  -- Types
  hi(0, '@type', { link = 'Type' })
  hi(0, '@type.builtin', { fg = C.yellow, italic = true })
  hi(0, '@type.definition', { link = '@type' })
  hi(0, '@type.qualifier', { link = '@type' })
  hi(0, '@storageclass', { link = 'StorageClass' })
  hi(0, '@attribute', { link = 'Constant' })
  hi(0, '@field', { fg = C.lavender })
  hi(0, '@property', { fg = C.lavender })

  -- Identifiers
  hi(0, '@variable', { fg = C.text })
  hi(0, '@variable.builtin', { fg = C.red })
  hi(0, '@constant', { fg = C.peach })
  hi(0, '@constant.builtin', { fg = C.peach })
  hi(0, '@constant.macro', { link = 'Macro' })
  hi(0, '@namespace', { fg = C.lavender, italic = true })
  hi(0, '@symbol', { fg = C.flamingo })

  -- Text
  hi(0, '@text', { fg = C.text })
  hi(0, '@text.strong', { fg = C.maroon, bold = true })
  hi(0, '@text.emphasis', { fg = C.maroon, italic = true })
  hi(0, '@text.underline', { link = 'Underline' })
  hi(0, '@text.strike', { fg = C.text, strikethrough = true })
  hi(0, '@text.title', { fg = C.blue, bold = true })
  hi(0, '@text.literal', { fg = C.teal })
  hi(0, '@text.uri', { fg = C.rosewater, italic = true, underline = true })
  hi(0, '@text.math', { fg = C.blue })
  hi(0, '@text.environment', { fg = C.pink })
  hi(0, '@text.environment.name', { fg = C.blue })
  hi(0, '@text.reference', { fg = C.lavender, bold = true })

  hi(0, '@text.todo', { fg = C.base, bg = C.yellow })
  hi(0, '@text.todo.checked', { fg = C.green })
  hi(0, '@text.todo.unchecked', { fg = C.overlay1 })
  hi(0, '@text.note', { fg = C.base, bg = C.blue })
  hi(0, '@text.warning', { fg = C.base, bg = C.yellow })
  hi(0, '@text.danger', { fg = C.base, bg = C.red })
  hi(0, '@text.diff.add', { link = 'diffAdded' })
  hi(0, '@text.diff.delete', { link = 'diffRemoved' })

  -- Tags
  hi(0, '@tag', { fg = C.mauve })
  hi(0, '@tag.attribute', { fg = C.teal, italic = true })
  hi(0, '@tag.delimiter', { fg = C.sky })

  -- Semantic tokens
  hi(0, '@class', { fg = C.blue })
  hi(0, '@struct', { fg = C.blue })
  hi(0, '@enum', { fg = C.teal })
  hi(0, '@enumMember', { fg = C.flamingo })
  hi(0, '@event', { fg = C.flamingo })
  hi(0, '@interface', { fg = C.flamingo })
  hi(0, '@modifier', { fg = C.flamingo })
  hi(0, '@regexp', { fg = C.pink })
  hi(0, '@typeParameter', { fg = C.yellow })
  hi(0, '@decorator', { fg = C.flamingo })

  -- Language specific:

  -- JS & derivative
  hi(0, '@keyword.export', { fg = C.sky, bold = true })

  -- css
  hi(0, '@property.css', { fg = C.lavender })
  hi(0, '@property.id.css', { fg = C.blue })
  hi(0, '@property.class.css', { fg = C.yellow })
  hi(0, '@type.css', { fg = C.lavender })
  hi(0, '@type.tag.css', { fg = C.mauve })
  hi(0, '@string.plain.css', { fg = C.peach })
  hi(0, '@number.css', { fg = C.peach })

  -- toml
  hi(0, '@property.toml', { fg = C.blue })

  -- json
  hi(0, '@label.json', { fg = C.blue })

  -- lua
  hi(0, '@constructor.lua', { fg = C.flamingo })

  -- typescript
  hi(0, '@constructor.typescript', { fg = C.lavender })

  -- TSX (Typescript React)
  hi(0, '@constructor.tsx', { fg = C.lavender })
  hi(0, '@tag.attribute.tsx', { fg = C.mauve, italic = true })

  -- cpp
  hi(0, '@property.cpp', { fg = C.rosewater })

  -- yaml
  hi(0, '@field.yaml', { fg = C.blue })

  -- Ruby
  hi(0, '@symbol.ruby', { fg = C.flamingo })

  -- PHP
  hi(0, '@type.qualifier.php', { fg = C.pink })
end

return M
