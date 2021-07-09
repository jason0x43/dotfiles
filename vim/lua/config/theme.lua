local base16 = require('base16')
local util = require('util')
local hi = util.hi

_G.theme = {}
local theme = _G.theme

-- apply customizations to the loaded theme
function theme.customize()
  local g = vim.g

  hi('Normal', { guibg = '', ctermbg = '' })
  hi('NormalFloat', { guibg = g.base16_gui01, ctermbg = '' })
  hi(
    'FloatBorder',
    { guibg = g.base16_gui01, guifg = g.base16_gui02, ctermbg = '' }
  )
  hi('Comment', { gui = 'italic' })
  hi('Visual', { guibg = g.base16_gui02, guifg = g.base16_gui00 })
  hi('MatchParen', { guibg = g.base16_gui02, guifg = g.base16_gui01 })
  hi('MatchParenCur', { guibg = g.base16_gui03, guifg = g.base16_gui00 })
  hi('Search', { guibg = g.base16_gui0D, guifg = g.base16_gui00 })
  hi('IncSearch', { guibg = g.base16_gui0D, guifg = g.base16_gui00 })
  hi('IncSearch', { guibg = g.base16_gui0D, guifg = g.base16_gui00 })
  hi('Error', { guibg = '', guifg = g.base16_gui0E })

  -- high visibility cursor
  hi('Cursor', { guibg = 'red' })

  -- no background for diffs (it messes with floating windows)
  hi('DiffAdded', { guibg = '' })
  hi('DiffFile', { guibg = '' })
  hi('DiffNewFile', { guibg = '' })
  hi('DiffLine', { guibg = '' })
  hi('DiffRemoved', { guibg = '' })
  hi('SpellBad', { guifg = g.base16_gui0E })

  hi('htmlItalic', { gui = 'italic', guifg = '', guibg = '' })
  hi('htmlBold', { gui = 'bold', guifg = '', guibg = '' })
  hi('htmlBoldItalic', { gui = 'italic,bold', guifg = '', guibg = '' })

  hi('MatchParen', { guifg = '', guibg = g.base16_gui01 })
  hi('MatchParenCur', { guifg = '', guibg = g.base16_gui01 })

  -- This doesn't currently work
  -- see https://github.com/neovim/neovim/issues/7018
  g.terminal_color_16 = g.base16_gui09
  g.terminal_color_17 = g.base16_gui0F
  g.terminal_color_18 = g.base16_gui01
  g.terminal_color_19 = g.base16_gui02
  g.terminal_color_20 = g.base16_gui04
  g.terminal_color_21 = g.base16_gui06

  local error_fg = g.base16_gui08
  local info_fg = g.base16_gui0D
  local warning_fg = g.base16_gui0A
  local hint_fg = g.base16_gui03
  local sign_bg = g.base16_gui01

  hi('LspDiagnosticsDefaultError', { guifg = error_fg })
  hi(
    'LspDiagnosticsSignError',
    { guifg = error_fg, guibg = sign_bg, gui = 'bold' }
  )

  hi('LspDiagnosticsDefaultHint', { guifg = hint_fg })
  hi(
    'LspDiagnosticsSignHint', { guifg = hint_fg, guibg = sign_bg, gui = 'bold' }
  )

  hi('LspDiagnosticsDefaultInformation', { guifg = info_fg })
  hi(
    'LspDiagnosticsSignInformation',
    { guifg = info_fg, guibg = sign_bg, gui = 'bold' }
  )

  hi('LspDiagnosticsDefaultWarning', { guifg = warning_fg })
  hi(
    'LspDiagnosticsSignWarning',
    { guifg = warning_fg, guibg = sign_bg, gui = 'bold' }
  )

  hi('LspDiagnosticsUnderlineError', { gui = 'undercurl', guisp = error_fg })
end

-- set the theme based on the value specified in ~/.vimrc_background
function theme.load_theme()
  local theme_file = util.home .. '/.vimrc_background'
  if util.file_exists(theme_file) then
    local lines = vim.fn.readfile(theme_file, '', 1)
    local words = vim.split(lines[1], '%s')
    local name = util.trim(words[#words], '\''):sub(8)
    base16(base16.themes[name], true)
    vim.g.colors_name = 'base16'
  end
end

-- apply customizations when the color scheme is updated
util.augroup('init_theme', { 'ColorScheme * call v:lua.theme.customize()' })

-- set the theme
theme.load_theme()

return theme
