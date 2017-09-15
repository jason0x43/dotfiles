" This setup code runs once
if !get(s:, 'ts_init', 0)
	let s:ts_init = 1

	function s:completeCursorWord(ArgLead, CmdLine, CursorPos)
		return expand('<cword>')
	endfunction
endif

" This setup code runs once per buffer
if !get(b:, 'ts_init', 0)
	let b:ts_init = 1

	command -buffer Def :YcmCompleter GoToDefinition
	command -buffer Refs :YcmCompleter GoToReferences
	command -buffer -nargs=1 -complete=custom,s:completeCursorWord Rename :YcmCompleter RefactorRename <args>
endif
