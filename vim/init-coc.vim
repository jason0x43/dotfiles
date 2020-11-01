" Set the registry for VIM to make COC happy
let $npm_config_registry='https://registry.npmjs.org'

let g:coc_node_path = '/usr/local/bin/node'

call coc#config('session.directory', expand('$CACHEDIR') . '/vim/sessions')

if !exists('g:fzf#vim#buffers')
  " <Leader>f to find files
  map <Leader>f :CocList files<CR>

  " <Leader>g to find files in a git repo
  map <Leader>g :CocList gfiles<CR>

  " <Leader>m to find modified files in a git repo
  map <Leader>m :CocList gstatus<CR>

  " <Leader>b to list buffers
  map <Leader>b :CocList buffers<CR>
endif

" Tab for cycling forwards through matches in a completion popup (taken
" from coc help)
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

" When popup menu is visible, tab goes to next entry.
" Else, if the cursor is in an active snippet, tab between fields.
" Else, if the character before the cursor isn't whitespace, put a Tab.
" Else, refresh the completion list
inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    \ <SID>check_back_space() ? "\<Tab>" :
    \ coc#refresh()

" Shift-Tab for cycling backwards through matches in a completion popup
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"

" Enter to confirm completion
inoremap <silent><expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

" K to show documentation in a preview window
function! s:show_documentation()
  if (index(['vim', 'help'], &filetype) >= 0)
    execute 'h ' . expand('<cword>')
  elseif exists(':CocAction')
    call CocAction('doHover')
  endif
endfunction
nnoremap <silent> K :call <SID>show_documentation()<CR>

augroup vimrc
  if exists('CocActionAsync')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  endif

  " nnoremap <expr><C-f> coc#util#has_float() ? coc#util#float_scroll(1) : "\<C-f>"
  " nnoremap <expr><C-b> coc#util#has_float() ? coc#util#float_scroll(0) : "\<C-b>"
augroup END

command! Rg :CocList --interactive grep<CR>

map <silent> <Leader>e :CocList diagnostics<cr>
map <silent> <Leader>l :CocList<CR>
map <silent> <Leader>x <Plug>(coc-codeaction)

map <silent> <M-f> <Plug>(coc-format)
map <silent> <C-]> <Plug>(coc-definition)
map <silent> <leader>t <Plug>(coc-format-selected)
map <silent> <leader>r <Plug>(coc-rename)
map <silent> <leader>j <Plug>(coc-references)
map <silent> <leader>d <Plug>(coc-diagnostic-info)

" navigate chunks of current buffer
nmap g[ <Plug>(coc-git-prevchunk)
nmap g] <Plug>(coc-git-nextchunk)
" show chunk diff at current position
nmap gi <Plug>(coc-git-chunkinfo)
" show commit contains current position (don't use gc)
nmap gl <Plug>(coc-git-commit)
" stage current chunk
nmap gu :CocCommand git.chunkStage<CR>
" undo current chunk
nmap g! :CocCommand git.chunkUndo<CR>
" fold everything but chunnks
nmap gf :CocCommand git.foldUnchanged<CR>

command! -nargs=0 OrganizeImports :CocCommand editor.action.organizeImport
command! -nargs=0 Prettier :CocCommand prettier.formatFile
command! -nargs=0 Format :call CocAction('format')

let g:coc_global_extensions = [
  \ 'coc-calc',
  \ 'coc-css',
  \ 'coc-emmet',
  \ 'coc-emoji',
  \ 'coc-eslint',
  \ 'coc-explorer',
  \ 'coc-git',
  \ 'coc-github',
  \ 'coc-highlight',
  \ 'coc-java',
  \ 'coc-jest',
  \ 'coc-json',
  \ 'coc-lists',
  \ 'coc-lua',
  \ 'coc-prettier',
  \ 'coc-python',
  \ 'coc-rls',
  \ 'coc-sh',
  \ 'coc-snippets',
  \ 'coc-svg',
  \ 'coc-tsserver',
  \ 'coc-vimlsp',
  \ 'coc-vimtex',
  \ 'coc-xml',
  \ 'coc-yaml',
  \ ]

let g:coc_status_error_sign = ' '
let g:coc_status_info_sign = ' '
let g:coc_status_hint_sign = ' '
let g:coc_status_warning_sign = ' '

let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<S-tab>'
let g:coc_disable_startup_warning = 1

function! s:coc_customize_colors()
  exec 'hi CocErrorSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0F . ' gui=bold'
  exec 'hi CocErrorVirtualText guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0F . ' gui=NONE'
  exec 'hi CocErrorHighlight gui=undercurl guisp=#' . g:base16_gui0F

  exec 'hi CocWarningSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui08 . ' gui=bold'
  exec 'hi CocWarningVirtualText guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui08 . ' gui=NONE'
  exec 'hi CocWarningHighlight gui=undercurl guisp=#' . g:base16_gui08

  exec 'hi CocInfoSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0B . ' gui=bold'
  exec 'hi CocInfoVirtualText guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0B . ' gui=NONE'
  exec 'hi CocInfoHighlight gui=undercurl guisp=#' . g:base16_gui0B

  exec 'hi CocHintSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0C . ' gui=bold'
  exec 'hi CocHintVirtualText guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0C . ' gui=NONE'
  exec 'hi CocHintHighlight gui=undercurl guisp=#' . g:base16_gui0C
endfunction

augroup vimrc
  autocmd ColorScheme * call s:coc_customize_colors()
augroup END

map <silent> <Leader>n :CocCommand explorer<CR>

function! LightlineGitBranch()
  return get(g:, 'coc_git_status', '')
endfunction

function! LightlineGitBlame()
  let l:blame = get(b:, 'coc_git_blame', '')
  if empty(l:blame) || l:blame[0] == 'Not committed yet'
    return ''
  endif
  return matchstr(l:blame, '^\zs([^)]\+)\ze')
endfunction

let g:lightline['component_function']['cocstatus'] = 'coc#status'
let g:lightline['component_function']['currentfunction'] = 'CocCurrentFunction'
let g:lightline['component_function']['gitbranch'] = 'LightlineGitBranch'
let g:lightline['component_function']['gitblame'] = 'LightlineGitBlame'
let g:lightline['active']['right'][1] = ['cocstatus', 'sleuth']
