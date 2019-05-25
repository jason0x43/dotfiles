au BufNewFile,BufRead *.applescript set filetype=applescript
au BufRead * call s:DetectApplescript()

function! s:DetectApplescript()
	if getline(1) == '#!/usr/bin/osascript'
		set filetype=applescript
    endif
endfunction
