function! s:detectJavaScript()
    if getline(1) == '#!/usr/bin/osascript -l JavaScript'
        set filetype=javascript
    endif
    if getline(1) == '#!/usr/bin/env zx'
        set filetype=javascript
    endif
endfunction

autocmd BufNewFile,BufRead * call s:detectJavaScript()
