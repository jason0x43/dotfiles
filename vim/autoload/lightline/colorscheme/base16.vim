function! lightline#colorscheme#base16#createpalette(palette)
    let l:base0 = [a:palette['base0']['gui'], a:palette['base0']['cterm']]
    let l:base1 = [a:palette['base1']['gui'], a:palette['base1']['cterm']]
    let l:base2 = [a:palette['base2']['gui'], a:palette['base2']['cterm']]
    let l:base3 = [a:palette['base3']['gui'], a:palette['base3']['cterm']]
    let l:base4 = [a:palette['base4']['gui'], a:palette['base4']['cterm']]
    let l:base5 = [a:palette['base5']['gui'], a:palette['base5']['cterm']]
    let l:base6 = [a:palette['base6']['gui'], a:palette['base6']['cterm']]
    let l:base7 = [a:palette['base7']['gui'], a:palette['base7']['cterm']]
    let l:base8 = [a:palette['base8']['gui'], a:palette['base8']['cterm']]
    let l:base9 = [a:palette['base9']['gui'], a:palette['base9']['cterm']]
    let l:baseA = [a:palette['baseA']['gui'], a:palette['baseA']['cterm']]
    let l:baseB = [a:palette['baseB']['gui'], a:palette['baseB']['cterm']]
    let l:baseC = [a:palette['baseC']['gui'], a:palette['baseC']['cterm']]
    let l:baseD = [a:palette['baseD']['gui'], a:palette['baseD']['cterm']]
    let l:baseE = [a:palette['baseE']['gui'], a:palette['baseE']['cterm']]
    let l:baseF = [a:palette['baseF']['gui'], a:palette['baseF']['cterm']]

    let l:p = {
        \ 'normal': {},
        \ 'inactive': {},
        \ 'insert': {},
        \ 'replace': {},
        \ 'visual': {},
        \ 'command': {},
        \ }

    let l:p.normal.left     = [ [ l:base0, l:base4 ], [ l:base0, l:base2 ] ]
    let l:p.insert.left     = [ [ l:base0, l:baseB ], [ l:base0, l:base2 ] ]
    let l:p.command.left    = [ [ l:base0, l:baseD ], [ l:base0, l:base2 ] ]
    let l:p.visual.left     = [ [ l:base0, l:baseE ], [ l:base0, l:base2 ] ]
    let l:p.replace.left    = [ [ l:base0, l:base8 ], [ l:base0, l:base2 ] ]
    let l:p.inactive.left   = [ [ l:base2, l:base1 ] ]

    let l:p.normal.middle   = [ [ l:base6, l:base1 ] ]
    let l:p.inactive.middle = [ [ l:base1, l:base1 ] ]

    let l:p.normal.right    = deepcopy(l:p.normal.left)
    let l:p.insert.right    = deepcopy(l:p.insert.left)
    let l:p.command.right    = deepcopy(l:p.command.left)
    let l:p.visual.right    = deepcopy(l:p.visual.left)
    let l:p.inactive.right  = [ [ l:base1, l:base1 ], [ l:base1, l:base1 ] ]

    let l:p.normal.error    = [ [ l:base1, l:base8 ] ]
    let l:p.normal.warning  = [ [ l:base1, l:baseA ] ]

    return lightline#colorscheme#flatten(l:p)
endfunction
