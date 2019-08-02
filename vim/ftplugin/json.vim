setlocal expandtab
setlocal shiftwidth=4
setlocal wrap
setlocal linebreak

map <buffer> j gj
map <buffer> k gk
map <buffer> 0 g0
map <buffer> $ g$

let fname = expand('%:t')
if fname ==? 'intern.json' || fname ==? 'tsconfig.json' || fname ==? 'coc-settings.json'
	setlocal commentstring=//\ %s
endif
