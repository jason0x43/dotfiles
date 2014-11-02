au BufRead *.html call s:DetectDjango()
au BufNewFile,BufRead *.jhtml set filetype=htmldjango

function! s:DetectDjango()
  let n = 0
  while n < 50
    let n = n + 1
    if getline(n) =~ '{[%{#]'
      set filetype=htmldjango
      break
    endif
  endwhile
endfunction
