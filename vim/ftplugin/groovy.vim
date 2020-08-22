" If buffer modified, update any 'Last modified: ' in the first 20 lines.
" 'Last modified: ' can have up to 10 characters before (they are retained).
" Restores cursor and window position using save_cursor variable.
function! s:lastModified()
	if &modified
		let save_cursor = getpos(".")
		let n = min([20, line("$")])
		keepjumps exe '1,' .
			\ n . 
			\ 's#^\(\s*\*\s*Last updated:\s*\).*#\1' .
			\ strftime('%Y-%m-%d, %T%z') .
			\ '#e'
		call histdel('search', -1)
		call setpos('.', save_cursor)
	endif
endfun

autocmd BufWritePre <buffer> call s:lastModified()
