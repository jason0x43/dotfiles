" This function should only be _after_ a base16 vim theme has been loaded
function lightline#colorscheme#base16#refresh()
    let s:base0 = [ '#' . g:base16_gui00,  0 ] " black
    let s:base1 = [ '#' . g:base16_gui01, 18 ]
    let s:base2 = [ '#' . g:base16_gui02, 19 ]
    let s:base3 = [ '#' . g:base16_gui03,  8 ]
    let s:base4 = [ '#' . g:base16_gui04, 20 ]
    let s:base5 = [ '#' . g:base16_gui05,  7 ]
    let s:base6 = [ '#' . g:base16_gui06, 21 ]
    let s:base7 = [ '#' . g:base16_gui07, 15 ] " white
    let s:base8 = [ '#' . g:base16_gui08,  1 ] " red
    let s:base9 = [ '#' . g:base16_gui09, 16 ] " orange
    let s:baseA = [ '#' . g:base16_gui0A,  3 ] " yellow
    let s:baseB = [ '#' . g:base16_gui0B,  2 ] " green
    let s:baseC = [ '#' . g:base16_gui0C,  6 ] " teal
    let s:baseD = [ '#' . g:base16_gui0D,  4 ] " blue
    let s:baseE = [ '#' . g:base16_gui0E,  5 ] " pink
    let s:baseF = [ '#' . g:base16_gui0F, 17 ] " brown

    let s:p = {
        \ 'command': {},
        \ 'inactive': {},
        \ 'insert': {},
        \ 'normal': {},
        \ 'replace': {},
        \ 'tabline': {},
        \ 'visual': {}
        \ }

    let s:p.normal.left     = [ [ s:base0, s:base4 ], [ s:base0, s:base2 ] ]
    let s:p.insert.left     = [ [ s:base0, s:baseB ], [ s:base0, s:base2 ] ]
    let s:p.command.left    = [ [ s:base0, s:baseD ], [ s:base0, s:base2 ] ]
    let s:p.visual.left     = [ [ s:base0, s:baseE ], [ s:base0, s:base2 ] ]
    let s:p.replace.left    = [ [ s:base0, s:base8 ], [ s:base0, s:base2 ] ]
    let s:p.inactive.left   = [ [ s:base2, s:base1 ] ]

    let s:p.normal.middle   = [ [ s:base6, s:base1 ] ]
    let s:p.inactive.middle = [ [ s:base1, s:base1 ] ]

    let s:p.normal.right    = deepcopy(s:p.normal.left)
    let s:p.insert.right    = deepcopy(s:p.insert.left)
    let s:p.command.right    = deepcopy(s:p.command.left)
    let s:p.visual.right    = deepcopy(s:p.visual.left)
    let s:p.inactive.right  = [ [ s:base1, s:base1 ], [ s:base1, s:base1] ]

    let s:p.normal.error    = [ [ s:base1, s:base8 ] ]
    let s:p.normal.warning  = [ [ s:base1, s:baseA ] ]

    let s:p.tabline.left    = [ [ s:base5, s:base2 ] ]
    let s:p.tabline.middle  = [ [ s:base5, s:base1 ] ]
    let s:p.tabline.right   = [ [ s:base5, s:base2 ] ]
    let s:p.tabline.tabsel  = [ [ s:base2, s:baseC ] ]

    let g:lightline#colorscheme#base16#palette = lightline#colorscheme#flatten(s:p)
endfunction

call lightline#colorscheme#base16#refresh()
