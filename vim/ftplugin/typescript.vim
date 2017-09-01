command! Definition :YcmCompleter GoToDefinition
command! -nargs=1 -complete=custom,s:completeCursorWord Rename :YcmCompleter RefactorRename 

function! s:completeCursorWord(ArgLead, CmdLine, CursorPos)
	return expand('<cword>')
endfunction
