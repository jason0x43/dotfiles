function! s:detectApplescript()
    if getline(1) == '#!/usr/bin/osascript'
        set filetype=applescript
    endif
endfunction

autocmd BufNewFile,BufRead * call s:detectApplescript()
