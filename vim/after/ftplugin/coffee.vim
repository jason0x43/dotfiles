setlocal shiftwidth=2

" for some reason this has to be enabled for matchit not to break standard
" matchpairs matching
let b:match_debug=1

" copied from $VIMRUNTIME/ftplugin/html.vim
if exists("loaded_matchit")
    let b:match_ignorecase = 1
    let b:match_words = '<:>,' .
        \ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
        \ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
        \ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>'
endif
