"setlocal formatoptions+=aw

" for some reason this has to be enabled for matchit not to break standard
" matchpairs matching
let b:match_debug=1

" copied from $VIMRUNTIME/ftplugin/html.vim
if exists("loaded_matchit")
  if exists("b:match_words")
    let match_words = b:match_words
  endif
  let b:match_words = '{%:%},' .
      \ '\<if\>:\<endif\>,\<with\>:\<endwith\>,' .
      \ '\<for\>:\<endfor\>,\<block\>:\<endblock\>'
  if exists("match_words")
    let b:match_words = b:match_words . ',' . match_words
  endif
endif
