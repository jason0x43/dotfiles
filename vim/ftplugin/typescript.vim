" This setup code runs once
if !get(s:, 'ts_init', 0)
	let s:ts_init = 1

	function s:completeCursorWord(ArgLead, CmdLine, CursorPos)
		return expand('<cword>')
	endfunction

	function s:prettierCheck(job_id, code, event)
		if a:code == 0
			let b:has_prettier = 1
		endif
	endfunction

	function s:prettierSave()
		if !get(b:, 'has_prettier', 0)
			return
		endif

		" Maintains cursor position when undoing a prettification
		" See http://vim.wikia.com/wiki/Restore_the_cursor_position_after_undoing_text_change_made_by_a_script
		normal! ix
		normal! x

		let l:view = winsaveview()
		execute "%! prettier --stdin --stdin-filepath %"
		call winrestview(l:view)
	endfunction
endif

" This setup code runs once per buffer
if !get(b:, 'ts_init', 0)
	let b:ts_init = 1

	command -buffer Def :YcmCompleter GoToDefinition
	command -buffer Refs :YcmCompleter GoToReferences
	command -buffer -nargs=1 -complete=custom,s:completeCursorWord Rename :YcmCompleter RefactorRename <args>

	augroup TsCmds
		autocmd! * <buffer>
		autocmd BufWritePre <buffer> call s:prettierSave()
	augroup END

	let job = jobstart(['prettier', '--find-config-path', expand('<afile>')], {
		\ 'on_exit': function('s:prettierCheck')
		\ })
endif
