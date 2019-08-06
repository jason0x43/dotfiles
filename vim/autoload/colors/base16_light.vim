" solarized light

let s:palette = {
    \ 'base0': { 'gui': '#fdf6e3', 'cterm':  0 },
    \ 'base1': { 'gui': '#eee8d5', 'cterm': 10 },
    \ 'base2': { 'gui': '#93a1a1', 'cterm': 11 },
    \ 'base3': { 'gui': '#839496', 'cterm':  8 },
    \ 'base4': { 'gui': '#657b83', 'cterm': 12 },
    \ 'base5': { 'gui': '#586e75', 'cterm':  7 },
    \ 'base6': { 'gui': '#073642', 'cterm': 13 },
    \ 'base7': { 'gui': '#002b36', 'cterm': 15 },
    \ 'base8': { 'gui': '#dc322f', 'cterm':  1 },
    \ 'base9': { 'gui': '#cb4b16', 'cterm':  9 },
    \ 'baseA': { 'gui': '#b58900', 'cterm':  3 },
    \ 'baseB': { 'gui': '#859900', 'cterm':  2 },
    \ 'baseC': { 'gui': '#2aa198', 'cterm':  6 },
    \ 'baseD': { 'gui': '#268bd2', 'cterm':  4 },
    \ 'baseE': { 'gui': '#6c71c4', 'cterm':  5 },
    \ 'baseF': { 'gui': '#d33682', 'cterm': 14 }
    \ }

function! colors#base16_light#palette()
    return s:palette
endfunction
