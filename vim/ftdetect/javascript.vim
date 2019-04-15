au BufNewFile,BufRead *.js set filetype=javascript
au BufNewFile,BufRead * call s:DetectJavaScript()

function! s:DetectJavaScript()
    if getline(1) == '#!/usr/bin/osascript -l JavaScript'
	set filetype=javascript
    endif
endfunction
