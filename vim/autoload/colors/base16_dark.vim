" ashes dark

let s:palette = {
    \ 'base0': { 'gui': '#1c2023', 'cterm':  0 },
    \ 'base1': { 'gui': '#393f45', 'cterm': 10 },
    \ 'base2': { 'gui': '#565e65', 'cterm': 11 },
    \ 'base3': { 'gui': '#747c84', 'cterm':  8 },
    \ 'base4': { 'gui': '#aeb3ba', 'cterm': 12 },
    \ 'base5': { 'gui': '#c7ccd1', 'cterm':  7 },
    \ 'base6': { 'gui': '#dfe2e5', 'cterm': 13 },
    \ 'base7': { 'gui': '#f3f4f5', 'cterm': 15 },
    \ 'base8': { 'gui': '#c7ae95', 'cterm':  1 },
    \ 'base9': { 'gui': '#c7c795', 'cterm':  9 },
    \ 'baseA': { 'gui': '#aec795', 'cterm':  3 },
    \ 'baseB': { 'gui': '#95c7ae', 'cterm':  2 },
    \ 'baseC': { 'gui': '#95aec7', 'cterm':  6 },
    \ 'baseD': { 'gui': '#ae95c7', 'cterm':  4 },
    \ 'baseE': { 'gui': '#c795ae', 'cterm':  5 },
    \ 'baseF': { 'gui': '#c79595', 'cterm': 14 }
    \ }

function! colors#base16_dark#palette()
    return s:palette
endfunction
