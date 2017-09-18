" This is a slimmed down and modified version of the solarized theme. In
" terminal mode, it assumes that the terminal palette will be adjusted for
" light vs dark modes, so the color palette here will not need to be updated.

hi clear

if exists('syntax_on')
	syntax reset
endif

let colors_name = 'solarized'

" ---------------------------------------------------------------------
" COLOR VALUES
" ---------------------------------------------------------------------
" Download palettes and files from: http://ethanschoonover.com/solarized
"
" SOLARIZED | HEX     | 16 | TERMCOL   | sRGB        | HSB
" ----------|---------|----|-----------|-------------|------------
" base03    | #002b36 |  8 | brblack   |   0  43  54 | 193 100  21
" base02    | #073642 |  0 | black     |   7  54  66 | 192  90  26
" base01    | #586e75 | 10 | brgreen   |  88 110 117 | 194  25  46
" base00    | #657b83 | 11 | bryellow  | 101 123 131 | 195  23  51
" base0     | #839496 | 12 | brblue    | 131 148 150 | 186  13  59
" base1     | #93a1a1 | 14 | brcyan    | 147 161 161 | 180   9  63
" base2     | #eee8d5 |  7 | white     | 238 232 213 |  44  11  93
" base3     | #fdf6e3 | 15 | brwhite   | 253 246 227 |  44  10  99
" yellow    | #b58900 |  3 | yellow    | 181 137   0 |  45 100  71
" orange    | #cb4b16 |  9 | brred     | 203  75  22 |  18  89  80
" red       | #dc322f |  1 | red       | 220  50  47 |   1  79  86
" magenta   | #d33682 |  5 | magenta   | 211  54 130 | 331  74  83
" violet    | #6c71c4 | 13 | brmagenta | 108 113 196 | 237  45  77
" blue      | #268bd2 |  4 | blue      |  38 139 210 | 205  82  82
" cyan      | #2aa198 |  6 | cyan      |  42 161 152 | 175  74  63
" green     | #859900 |  2 | green     | 133 153   0 |  68 100  60

" Configure a highlight group
function! s:highlight(group, style, fg, bg)
	let l:guifg = eval('s:gui_' . a:fg)
	let l:guibg = eval('s:gui_' . a:bg)
	let l:ctermfg = eval('s:cterm_' . a:fg)
	let l:ctermbg = eval('s:cterm_' . a:bg)
	exe "hi! " . a:group
		\ . " cterm=" . a:style
		\ . " ctermfg=" . l:ctermfg
		\ . " ctermbg=" . l:ctermbg
		\ . " gui=" . a:style
		\ . " guifg=" . l:guifg
		\ . " guibg=" . l:guibg
endfunction

" GUI palette
" ---------------------------------------------------------------------
let s:gui_base03        = "#002b36"
let s:gui_base02        = "#073642"
let s:gui_base01        = "#586e75"
let s:gui_base00        = "#657b83"
let s:gui_base0         = "#839496"
let s:gui_base1         = "#93a1a1"
let s:gui_base2         = "#eee8d5"
let s:gui_base3         = "#fdf6e3"
let s:gui_yellow        = "#b58900"
let s:gui_orange        = "#cb4b16"
let s:gui_red           = "#dc322f"
let s:gui_magenta       = "#d33682"
let s:gui_violet        = "#6c71c4"
let s:gui_blue          = "#268bd2"
let s:gui_cyan          = "#2aa198"
let s:gui_green         = "#859900"
let s:gui_NONE          = "NONE"

" cterm palette
" ---------------------------------------------------------------------
let s:cterm_base03      = "8"
let s:cterm_base02      = "0"
let s:cterm_base01      = "10"
let s:cterm_base00      = "11"
let s:cterm_base0       = "12"
let s:cterm_base1       = "14"
let s:cterm_base2       = "7"
let s:cterm_base3       = "15"
let s:cterm_yellow      = "3"
let s:cterm_orange      = "9"
let s:cterm_red         = "1"
let s:cterm_magenta     = "5"
let s:cterm_violet      = "13"
let s:cterm_blue        = "4"
let s:cterm_cyan        = "6"
let s:cterm_green       = "2"
let s:cterm_NONE        = "NONE"

" Neovim terminal palette
" ---------------------------------------------------------------------
let g:terminal_color_0  = s:gui_base02
let g:terminal_color_1  = s:gui_red
let g:terminal_color_2  = s:gui_green
let g:terminal_color_3  = s:gui_yellow
let g:terminal_color_4  = s:gui_blue
let g:terminal_color_5  = s:gui_magenta
let g:terminal_color_6  = s:gui_cyan
let g:terminal_color_7  = s:gui_base2
let g:terminal_color_8  = s:gui_base03
let g:terminal_color_9  = s:gui_orange
let g:terminal_color_10 = s:gui_base01
let g:terminal_color_11 = s:gui_base00
let g:terminal_color_12 = s:gui_base0
let g:terminal_color_13 = s:gui_violet
let g:terminal_color_14 = s:gui_base1
let g:terminal_color_15 = s:gui_base3

" Group links
" ---------------------------------------------------------------------
hi link lCursor           Cursor

hi link vimFunc           Function
hi link vimUserFunc       Function
hi link vipmVar           Identifier

hi link diffAdded         Statement
hi link diffLine          Identifier

hi link helpHyperTextJump Underlined

" Extended colors
" ---------------------------------------------------------------------
call s:highlight('ColorColumn',  'NONE',      'NONE',    'base2')
call s:highlight('Conceal',      'NONE',      'blue',    'NONE')
call s:highlight('Cursor',       'NONE',      'base3',   'base00')
call s:highlight('CursorColumn', 'NONE',      'NONE',    'base2')
call s:highlight('CursorLine',   'NONE',      'NONE',    'base2')
call s:highlight('CursorLineNr', 'bold',      'NONE',    'base2')
call s:highlight('DiffAdd',      'bold',      'green',   'base2')
call s:highlight('DiffChange',   'bold',      'yellow',  'base2')
call s:highlight('DiffDelete',   'bold',      'red',     'base2')
call s:highlight('DiffText',     'bold',      'blue',    'base2')
call s:highlight('Directory',    'NONE',      'blue',    'NONE')
call s:highlight('ErrorMsg',     'reverse',   'red',     'NONE')
call s:highlight('ErrorSign',    'NONE',      'red',     'base2')
call s:highlight('FoldColumn',   'NONE',      'base1',   'base2')
call s:highlight('Folded',       'underline', 'base1',   'base2')
call s:highlight('IncSearch',    'standout',  'orange',  'NONE')
call s:highlight('LineNr',       'NONE',      'base1',   'base2')
call s:highlight('MatchParen',   'bold',      'red',     'base1')
call s:highlight('ModeMsg',      'NONE',      'blue',    'NONE')
call s:highlight('MoreMsg',      'NONE',      'blue',    'NONE')
call s:highlight('NonText',      'bold',      'base0',   'NONE')
call s:highlight('Pmenu',        'NONE',      'base00',  'base2')
call s:highlight('PmenuSbar',    'NONE',      'base02',  'base00')
call s:highlight('PmenuSel',     'NONE',      'base1',   'base02')
call s:highlight('PmenuThumb',   'NONE',      'base00',  'base3')
call s:highlight('Question',     'bold',      'cyan',    'NONE')
call s:highlight('Search',       'reverse',   'yellow',  'NONE')
call s:highlight('SignColumn',   'NONE',      'base00',  'NONE')
call s:highlight('SpecialKey',   'bold',      'base0',   'base2')
call s:highlight('SpellBad',     'undercurl', 'magenta', 'NONE')
call s:highlight('SpellCap',     'undercurl', 'NONE',    'NONE')
call s:highlight('SpellLocal',   'undercurl', 'NONE',    'NONE')
call s:highlight('SpellRare',    'undercurl', 'NONE',    'NONE')
call s:highlight('StatusLine',   'NONE',      'base01',  'base2')
call s:highlight('StatusLineNC', 'NONE',      'base0',   'base2')
call s:highlight('TabLine',      'underline', 'base00',  'base2')
call s:highlight('TabLineFill',  'underline', 'base00',  'base2')
call s:highlight('TabLineSel',   'underline', 'base1',   'NONE')
call s:highlight('Title',        'bold',      'orange',  'NONE')
call s:highlight('VertSplit',    'NONE',      'base0',   'NONE')
call s:highlight('Visual',       'NONE',      'base1',   'base2')
call s:highlight('WarningMsg',   'NONE',      'orange',  'NONE')
call s:highlight('WarningSign',  'NONE',      'yellow',  'base2')
call s:highlight('WildMenu',     'NONE',      'base02',  'base2')

" Enable the solarized palette
function! s:solarize(bang)
	if a:bang == ""
		let l:normal_bg = 'NONE'
		if has("gui")
			let l:normal_bg = 'base3'
		endif

		call s:highlight('Comment',      'italic',    'base1',   'NONE')
		call s:highlight('Constant',     'NONE',      'cyan',    'NONE')
		call s:highlight('Error',        'NONE',      'red',     'NONE')
		call s:highlight('Identifier',   'NONE',      'blue',    'NONE')
		call s:highlight('Ignore',       'NONE',      'NONE',    'NONE')
		call s:highlight('Normal',       'NONE',      'base00',  l:normal_bg)
		call s:highlight('PreProc',      'NONE',      'orange',  'NONE')
		call s:highlight('Special',      'NONE',      'red',     'NONE')
		call s:highlight('Statement',    'NONE',      'green',   'NONE')
		call s:highlight('Todo',         'NONE',      'magenta', 'NONE')
		call s:highlight('Type',         'NONE',      'yellow',  'NONE')
		call s:highlight('Underlined',   'underline', 'violet',  'NONE')
	else
		" Dim the palette
		call s:highlight('Comment',    'italic',    'base1', 'NONE')
		call s:highlight('Constant',   'NONE',      'base1', 'NONE')
		call s:highlight('Error',      'NONE',      'base1', 'NONE')
		call s:highlight('Identifier', 'NONE',      'base1', 'NONE')
		call s:highlight('Ignore',     'NONE',      'base1', 'NONE')
		call s:highlight('Normal',     'NONE',      'base1', 'NONE')
		call s:highlight('PreProc',    'NONE',      'base1', 'NONE')
		call s:highlight('Special',    'NONE',      'base1', 'NONE')
		call s:highlight('Statement',  'NONE',      'base1', 'NONE')
		call s:highlight('Todo',       'NONE',      'base1', 'NONE')
		call s:highlight('Type',       'NONE',      'base1', 'NONE')
		call s:highlight('Underlined', 'underline', 'base1', 'NONE')
	endif
endfunction

command! -bang Solarize call s:solarize('<bang>')

call s:solarize("")
