if !executable('fzf') || !exists('g:tss_loaded')
	finish
endif

function! s:ts_tags()
	call fzf#run({
		\ 'options': '-s -d "\t" --with-nth 4,1 -n 1 --tiebreak=index',
		\ 'source': tss#tags(),
		\ 'sink': function('s:tags_sink'),
		\ 'down': '20%'
		\ })
endfunction

function! s:tags_sink(line)
	execute split(a:line, "\t")[2]
endfunction

command! TsTags call s:ts_tags()

" map <silent> <Leader>t :TsTags<CR>

let g:neomake_typescript_tslint_maker = {
	\ 'exe': 'tslint',
	\ 'args': [ '%:p' ],
	\ 'errorformat': '%EERROR: %f[%l\, %c]: %m'
	\ }
