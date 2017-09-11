" This setup code runs once
if !get(s:, 'ts_init', 0)
	let s:ts_init = 1

	function s:completeCursorWord(ArgLead, CmdLine, CursorPos)
		return expand('<cword>')
	endfunction

	function s:prettierCheck(job_id, code, event)
		if a:code == 0
			echom 'set has_prettier'
			let b:has_prettier = 1
		endif
	endfunction

	function s:prettierSave()
		if !get(b:, 'has_prettier', 0)
			return
		endif

		let l:view = winsaveview()
		execute "%! prettier --stdin --stdin-filepath %"
		call winrestview(l:view)
	endfunction
endif

" This setup code runs once per buffer
if !get(b:, 'ts_init', 0)
	let b:ts_init = 1

	command -buffer Definition :YcmCompleter GoToDefinition
	command -buffer -nargs=1 -complete=custom,s:completeCursorWord Rename :YcmCompleter RefactorRename <args>

	autocmd BufWritePre <buffer> call s:prettierSave()

	let job = jobstart(['prettier', '--find-config-path', expand('<afile>')], {
		\ 'on_exit': function('s:prettierCheck')
		\ })
endif
