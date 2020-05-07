function! s:detectTypeScript()
    if getline(1) == '#!/usr/local/bin/deno'
        set filetype=typescript
    endif
    if getline(1) == '#!/usr/bin/env deno'
        set filetype=typescript
    endif
endfunction

autocmd BufNewFile,BufRead * call s:detectTypeScript()
