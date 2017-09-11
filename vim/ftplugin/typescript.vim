" Ensure this setup code is only run once per buffer
if get(b:, 'ts_init', 0)
	finish
endif
let b:ts_init = 1

augroup TsPrettier
	autocmd!
augroup END

command! -buffer Definition :YcmCompleter GoToDefinition
command! -buffer -nargs=1 -complete=custom,s:completeCursorWord Rename :YcmCompleter RefactorRename <args>

function! s:completeCursorWord(ArgLead, CmdLine, CursorPos)
	return expand('<cword>')
endfunction

" If a prettierrc is available, run prettier when saving the file
function! s:prettierCheck(job_id, code, event)
	if a:code == 0
		autocmd TsPrettier BufWritePre <buffer> let s:view = winsaveview()
			\ | execute "%! prettier --stdin --stdin-filepath %"
			\ | call winrestview(s:view)
	endif
endfunction

let job = jobstart(['prettier', '--find-config-path', expand('<afile>')], {
	\ 'on_exit': function('s:prettierCheck')
	\ })
