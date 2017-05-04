" This is a slimmed down and modified version of the solarized theme. In
" terminal mode, it assumes that the terminal palette will be adjusted for
" light vs dark modes, so the color palette here will not need to be updated.

" ---------------------------------------------------------------------
" COLOR VALUES
" ---------------------------------------------------------------------
" Download palettes and files from: http://ethanschoonover.com/solarized
"
" L\*a\*b values are canonical (White D65, Reference D50), other values are
" matched in sRGB space.
"
" SOLARIZED HEX     16/8 TERMCOL  XTERM/HEX   L*A*B      sRGB        HSB
" --------- ------- ---- -------  ----------- ---------- ----------- -----------
" base03    #002b36  8/4 brblack  234 #1c1c1c 15 -12 -12   0  43  54 193 100  21
" base02    #073642  0/4 black    235 #262626 20 -12 -12   7  54  66 192  90  26
" base01    #586e75 10/7 brgreen  240 #4e4e4e 45 -07 -07  88 110 117 194  25  46
" base00    #657b83 11/7 bryellow 241 #585858 50 -07 -07 101 123 131 195  23  51
" base0     #839496 12/6 brblue   244 #808080 60 -06 -03 131 148 150 186  13  59
" base1     #93a1a1 14/4 brcyan   245 #8a8a8a 65 -05 -02 147 161 161 180   9  63
" base2     #eee8d5  7/7 white    254 #d7d7af 92 -00  10 238 232 213  44  11  93
" base3     #fdf6e3 15/7 brwhite  230 #ffffd7 97  00  10 253 246 227  44  10  99
" yellow    #b58900  3/3 yellow   136 #af8700 60  10  65 181 137   0  45 100  71
" orange    #cb4b16  9/3 brred    166 #d75f00 50  50  55 203  75  22  18  89  80
" red       #dc322f  1/1 red      160 #d70000 50  65  45 220  50  47   1  79  86
" magenta   #d33682  5/5 magenta  125 #af005f 50  65 -05 211  54 130 331  74  83
" violet    #6c71c4 13/5 brmagenta 61 #5f5faf 50  15 -45 108 113 196 237  45  77
" blue      #268bd2  4/4 blue      33 #0087ff 55 -10 -45  38 139 210 205  82  82
" cyan      #2aa198  6/6 cyan      37 #00afaf 60 -35 -05  42 161 152 175  74  63
" green     #859900  2/2 green     64 #5f8700 60 -20  65 133 153   0  68 100  60

if !exists('g:solarized_bold')
	let g:solarized_bold = 1
endif

if !exists('g:solarized_underline')
	let g:solarized_underline = 1
endif

if !exists('g:solarized_italic')
	let g:solarized_italic = 1
endif

let s:use_gui_colors = has("gui_running") || &termguicolors

" GUI & CSApprox hexadecimal palettes"
" ---------------------------------------------------------------------
if s:use_gui_colors
    let s:vmode       = "gui"
    let s:base03      = "#002b36"
    let s:base02      = "#073642"
    let s:base01      = "#586e75"
    let s:base00      = "#657b83"
    let s:base0       = "#839496"
    let s:base1       = "#93a1a1"
    let s:base2       = "#eee8d5"
    let s:base3       = "#fdf6e3"
    let s:yellow      = "#b58900"
    let s:orange      = "#cb4b16"
    let s:red         = "#dc322f"
    let s:magenta     = "#d33682"
    let s:violet      = "#6c71c4"
    let s:blue        = "#268bd2"
    let s:cyan        = "#2aa198"
    let s:green       = "#859900"
else
    let s:vmode       = "cterm"
    let s:base03      = "8"
    let s:base02      = "0"
    let s:base01      = "10"
    let s:base00      = "11"
    let s:base0       = "12"
    let s:base1       = "14"
    let s:base2       = "7"
    let s:base3       = "15"
    let s:yellow      = "3"
    let s:orange      = "9"
    let s:red         = "1"
    let s:magenta     = "5"
    let s:violet      = "13"
    let s:blue        = "4"
    let s:cyan        = "6"
    let s:green       = "2"
endif

" Formatting options and null values for passthrough effect
" ---------------------------------------------------------------------
let s:none = "NONE"
let s:c    = ",undercurl"
let s:r    = ",reverse"
let s:s    = ",standout"

" Background value in terminal is managed by the terminal
" ---------------------------------------------------------------------
if s:use_gui_colors
    let s:back = s:base3
else
    let s:back = "NONE"
endif

" Overrides dependent on user specified values and environment
" ---------------------------------------------------------------------
if g:solarized_bold == 0
    let s:b  = ""
    let s:bb = ",bold"
else
    let s:b  = ",bold"
    let s:bb = ""
endif

if g:solarized_underline == 0
    let s:u = ""
else
    let s:u = ",underline"
endif

if g:solarized_italic == 0
    let s:i = ""
else
    let s:i = ",italic"
endif

" Highlighting primitives
" ---------------------------------------------------------------------
let s:bg_none    = ' '.s:vmode.'bg='.s:none
let s:bg_back    = ' '.s:vmode.'bg='.s:back
let s:bg_base03  = ' '.s:vmode.'bg='.s:base03
let s:bg_base02  = ' '.s:vmode.'bg='.s:base02
let s:bg_base01  = ' '.s:vmode.'bg='.s:base01
let s:bg_base00  = ' '.s:vmode.'bg='.s:base00
let s:bg_base0   = ' '.s:vmode.'bg='.s:base0
let s:bg_base1   = ' '.s:vmode.'bg='.s:base1
let s:bg_base2   = ' '.s:vmode.'bg='.s:base2
let s:bg_base3   = ' '.s:vmode.'bg='.s:base3
let s:bg_green   = ' '.s:vmode.'bg='.s:green
let s:bg_yellow  = ' '.s:vmode.'bg='.s:yellow
let s:bg_orange  = ' '.s:vmode.'bg='.s:orange
let s:bg_red     = ' '.s:vmode.'bg='.s:red
let s:bg_magenta = ' '.s:vmode.'bg='.s:magenta
let s:bg_violet  = ' '.s:vmode.'bg='.s:violet
let s:bg_blue    = ' '.s:vmode.'bg='.s:blue
let s:bg_cyan    = ' '.s:vmode.'bg='.s:cyan

let s:fg_none    = ' '.s:vmode.'fg='.s:none
let s:fg_back    = ' '.s:vmode.'fg='.s:back
let s:fg_base03  = ' '.s:vmode.'fg='.s:base03
let s:fg_base02  = ' '.s:vmode.'fg='.s:base02
let s:fg_base01  = ' '.s:vmode.'fg='.s:base01
let s:fg_base00  = ' '.s:vmode.'fg='.s:base00
let s:fg_base0   = ' '.s:vmode.'fg='.s:base0
let s:fg_base1   = ' '.s:vmode.'fg='.s:base1
let s:fg_base2   = ' '.s:vmode.'fg='.s:base2
let s:fg_base3   = ' '.s:vmode.'fg='.s:base3
let s:fg_green   = ' '.s:vmode.'fg='.s:green
let s:fg_yellow  = ' '.s:vmode.'fg='.s:yellow
let s:fg_orange  = ' '.s:vmode.'fg='.s:orange
let s:fg_red     = ' '.s:vmode.'fg='.s:red
let s:fg_magenta = ' '.s:vmode.'fg='.s:magenta
let s:fg_violet  = ' '.s:vmode.'fg='.s:violet
let s:fg_blue    = ' '.s:vmode.'fg='.s:blue
let s:fg_cyan    = ' '.s:vmode.'fg='.s:cyan

let s:fmt_none   = ' '.s:vmode.'=NONE'.        ' term=NONE'
let s:fmt_bold   = ' '.s:vmode.'=NONE'.s:b.    ' term=NONE'.s:b
let s:fmt_bldi   = ' '.s:vmode.'=NONE'.s:b.    ' term=NONE'.s:b
let s:fmt_undr   = ' '.s:vmode.'=NONE'.s:u.    ' term=NONE'.s:u
let s:fmt_undb   = ' '.s:vmode.'=NONE'.s:u.s:b.' term=NONE'.s:u.s:b
let s:fmt_undi   = ' '.s:vmode.'=NONE'.s:u.    ' term=NONE'.s:u
let s:fmt_uopt   = ' '.s:vmode.'=NONE'.        ' term=NONE'
let s:fmt_curl   = ' '.s:vmode.'=NONE'.s:c.    ' term=NONE'.s:c
let s:fmt_ital   = ' '.s:vmode.'=NONE'.s:i.    ' term=NONE'.s:i
let s:fmt_stnd   = ' '.s:vmode.'=NONE'.s:s.    ' term=NONE'.s:s
let s:fmt_revr   = ' '.s:vmode.'=NONE'.s:r.    ' term=NONE'.s:r
let s:fmt_revb   = ' '.s:vmode.'=NONE'.s:r.s:b.' term=NONE'.s:r.s:b

" Special colors are for the undercurl
if s:use_gui_colors
    let s:sp_none    = ' guisp='.s:none
    let s:sp_back    = ' guisp='.s:back
    let s:sp_base03  = ' guisp='.s:base03
    let s:sp_base02  = ' guisp='.s:base02
    let s:sp_base01  = ' guisp='.s:base01
    let s:sp_base00  = ' guisp='.s:base00
    let s:sp_base0   = ' guisp='.s:base0
    let s:sp_base1   = ' guisp='.s:base1
    let s:sp_base2   = ' guisp='.s:base2
    let s:sp_base3   = ' guisp='.s:base3
    let s:sp_green   = ' guisp='.s:green
    let s:sp_yellow  = ' guisp='.s:yellow
    let s:sp_orange  = ' guisp='.s:orange
    let s:sp_red     = ' guisp='.s:red
    let s:sp_magenta = ' guisp='.s:magenta
    let s:sp_violet  = ' guisp='.s:violet
    let s:sp_blue    = ' guisp='.s:blue
    let s:sp_cyan    = ' guisp='.s:cyan
else
    let s:sp_none    = ""
    let s:sp_back    = ""
    let s:sp_base03  = ""
    let s:sp_base02  = ""
    let s:sp_base01  = ""
    let s:sp_base00  = ""
    let s:sp_base0   = ""
    let s:sp_base1   = ""
    let s:sp_base2   = ""
    let s:sp_base3   = ""
    let s:sp_green   = ""
    let s:sp_yellow  = ""
    let s:sp_orange  = ""
    let s:sp_red     = ""
    let s:sp_magenta = ""
    let s:sp_violet  = ""
    let s:sp_blue    = ""
    let s:sp_cyan    = ""
endif

" Basic highlighting
" ---------------------------------------------------------------------
exe "hi! Normal"         .s:fmt_none   .s:fg_base00   .s:bg_back

exe "hi! Comment"        .s:fmt_ital   .s:fg_base1    .s:bg_none
"       *Comment         any comment

exe "hi! Constant"       .s:fmt_none   .s:fg_cyan     .s:bg_none
"       *Constant        any constant
"        String          a string constant: "this is a string"
"        Character       a character constant: 'c', '\n'
"        Number          a number constant: 234, 0xff
"        Boolean         a boolean constant: TRUE, false
"        Float           a floating point constant: 2.3e10

exe "hi! Identifier"     .s:fmt_none   .s:fg_blue     .s:bg_none
"       *Identifier      any variable name
"        Function        function name (also: methods for classes)
"
exe "hi! Statement"      .s:fmt_none   .s:fg_green    .s:bg_none
"       *Statement       any statement
"        Conditional     if, then, else, endif, switch, etc.
"        Repeat          for, do, while, etc.
"        Label           case, default, etc.
"        Operator        "sizeof", "+", "*", etc.
"        Keyword         any other keyword
"        Exception       try, catch, throw

exe "hi! PreProc"        .s:fmt_none   .s:fg_orange   .s:bg_none
"       *PreProc         generic Preprocessor
"        Include         preprocessor #include
"        Define          preprocessor #define
"        Macro           same as Define
"        PreCondit       preprocessor #if, #else, #endif, etc.

exe "hi! Type"           .s:fmt_none   .s:fg_yellow   .s:bg_none
"       *Type            int, long, char, etc.
"        StorageClass    static, register, volatile, etc.
"        Structure       struct, union, enum, etc.
"        Typedef         A typedef

exe "hi! Special"        .s:fmt_none   .s:fg_red      .s:bg_none
"       *Special         any special symbol
"        SpecialChar     special character in a constant
"        Tag             you can use CTRL-] on this
"        Delimiter       character that needs attention
"        SpecialComment  special things inside a comment
"        Debug           debugging statements

exe "hi! Underlined"     .s:fmt_none   .s:fg_violet   .s:bg_none
"       *Underlined      text that stands out, HTML links

exe "hi! Ignore"         .s:fmt_none   .s:fg_none     .s:bg_none
"       *Ignore          left blank, hidden  |hl-Ignore|

exe "hi! Error"          .s:fmt_bold   .s:fg_red      .s:bg_none
"       *Error           any erroneous construct

exe "hi! Todo"           .s:fmt_none   .s:fg_magenta  .s:bg_none
"       *Todo            anything that needs extra attention; mostly the
"                        keywords TODO FIXME and XXX

" Extended highlighting
" ---------------------------------------------------------------------
hi! link lCursor Cursor

exe "hi! ColorColumn"  .s:fmt_none .s:fg_none    .s:bg_base2
exe "hi! Conceal"      .s:fmt_none .s:fg_blue    .s:bg_none
exe "hi! Cursor"       .s:fmt_none .s:fg_base3   .s:bg_base00
exe "hi! CursorColumn" .s:fmt_none .s:fg_none    .s:bg_base2
exe "hi! CursorLine"   .s:fmt_uopt .s:fg_none    .s:bg_base2   .s:sp_base01
exe "hi! CursorLineNr" .s:fmt_bold .s:fg_none    .s:bg_base2   .s:sp_base01
exe "hi! Directory"    .s:fmt_none .s:fg_blue    .s:bg_none
exe "hi! ErrorMsg"     .s:fmt_revr .s:fg_red     .s:bg_none
exe "hi! FoldColumn"   .s:fmt_none .s:fg_base1   .s:bg_base2
exe "hi! Folded"       .s:fmt_undb .s:fg_base1   .s:bg_base2   .s:sp_base3
exe "hi! IncSearch"    .s:fmt_stnd .s:fg_orange  .s:bg_none
exe "hi! LineNr"       .s:fmt_none .s:fg_base1   .s:bg_base2
exe "hi! MatchParen"   .s:fmt_bold .s:fg_red     .s:bg_base1
exe "hi! ModeMsg"      .s:fmt_none .s:fg_blue    .s:bg_none
exe "hi! MoreMsg"      .s:fmt_none .s:fg_blue    .s:bg_none
exe "hi! NonText"      .s:fmt_bold .s:fg_base0   .s:bg_none
exe "hi! Pmenu"        .s:fmt_none .s:fg_base00  .s:bg_base2
exe "hi! PmenuSbar"    .s:fmt_none .s:fg_base02  .s:bg_base00
exe "hi! PmenuSel"     .s:fmt_none .s:fg_base1   .s:bg_base02
exe "hi! PmenuThumb"   .s:fmt_none .s:fg_base00  .s:bg_base3
exe "hi! Question"     .s:fmt_bold .s:fg_cyan    .s:bg_none
exe "hi! Search"       .s:fmt_revr .s:fg_yellow  .s:bg_none
exe "hi! SignColumn"   .s:fmt_none .s:fg_base00  .s:bg_none
exe "hi! SpecialKey"   .s:fmt_bold .s:fg_base0   .s:bg_base2
exe "hi! SpellBad"     .s:fmt_curl .s:fg_magenta .s:bg_none    .s:sp_red
exe "hi! SpellCap"     .s:fmt_curl .s:fg_none    .s:bg_none    .s:sp_violet
exe "hi! SpellLocal"   .s:fmt_curl .s:fg_none    .s:bg_none    .s:sp_yellow
exe "hi! SpellRare"    .s:fmt_curl .s:fg_none    .s:bg_none    .s:sp_cyan
exe "hi! StatusLine"   .s:fmt_none .s:fg_base01  .s:bg_base2
exe "hi! StatusLineNC" .s:fmt_none .s:fg_base0   .s:bg_base2
exe "hi! TabLine"      .s:fmt_undr .s:fg_base00  .s:bg_base2   .s:sp_base00
exe "hi! TabLineFill"  .s:fmt_undr .s:fg_base00  .s:bg_base2   .s:sp_base00
exe "hi! TabLineSel"   .s:fmt_undr .s:fg_base1   .s:bg_none
exe "hi! Title"        .s:fmt_bold .s:fg_orange  .s:bg_none
exe "hi! Visual"       .s:fmt_none .s:fg_base1   .s:bg_base2
exe "hi! WarningMsg"   .s:fmt_bold .s:fg_red     .s:bg_none
exe "hi! WildMenu"     .s:fmt_none .s:fg_base02  .s:bg_base2

if s:use_gui_colors
	exe "hi! VertSplit"  .s:fmt_none .s:fg_base0  .s:none
	exe "hi! DiffAdd"    .s:fmt_bold .s:fg_green  .s:bg_base2 .s:sp_green
	exe "hi! DiffChange" .s:fmt_bold .s:fg_yellow .s:bg_base2 .s:sp_yellow
	exe "hi! DiffDelete" .s:fmt_bold .s:fg_red    .s:bg_base2
	exe "hi! DiffText"   .s:fmt_bold .s:fg_blue   .s:bg_base2 .s:sp_blue
else
	exe "hi! VertSplit"  .s:fmt_none .s:fg_base0  .s:none
	exe "hi! DiffAdd"    .s:fmt_none .s:fg_green  .s:bg_base2 .s:sp_green
	exe "hi! DiffChange" .s:fmt_none .s:fg_yellow .s:bg_base2 .s:sp_yellow
	exe "hi! DiffDelete" .s:fmt_none .s:fg_red    .s:bg_base2
	exe "hi! DiffText"   .s:fmt_none .s:fg_blue   .s:bg_base2 .s:sp_blue
endif

" Custom highligting
" ---------------------------------------------------------------------
exe "hi! WarningSign"  .s:fmt_none .s:fg_yellow .s:bg_base2
exe "hi! ErrorSign"    .s:fmt_none .s:fg_red    .s:bg_base2

" Neovim terminal palette
" ---------------------------------------------------------------------
let g:terminal_color_0  = s:base02
let g:terminal_color_1  = s:red
let g:terminal_color_2  = s:green
let g:terminal_color_3  = s:yellow
let g:terminal_color_4  = s:blue
let g:terminal_color_5  = s:magenta
let g:terminal_color_6  = s:cyan
let g:terminal_color_7  = s:base2
let g:terminal_color_8  = s:base03
let g:terminal_color_9  = s:orange
let g:terminal_color_10 = s:base01
let g:terminal_color_11 = s:base00
let g:terminal_color_12 = s:base0
let g:terminal_color_13 = s:violet
let g:terminal_color_14 = s:base1
let g:terminal_color_15 = s:base3
