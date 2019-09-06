" There might be special characters in here
scriptencoding utf8

" Clear out any autocommands defined here
augroup vimrc
    autocmd!
augroup END

" Check for vim-plug; install if missing
let plugpath = expand('<sfile>:p:h') . '/autoload/plug.vim'
if !filereadable(plugpath)
    if executable('curl')
        call system('curl -fLo ' . shellescape(plugpath) . ' --create-dirs ' . 
            \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
        if v:shell_error
            echo "Error downloading vim-plug. Please install it manually.\n"
            exit
        endif
    else
        echo "Unable to download vim-plug. Please install it manually or install curl.\n"
        exit
    endif
endif

" Put all swap and undo files in a central location
if exists('$CACHEDIR')
    set directory=$CACHEDIR/vim/swap//
    set undodir=$CACHEDIR/vim/undo//
    set backupdir=$CACHEDIR/vim/backup//

    " neovim uses shada rather than viminfo
    if !has('nvim')
        set viminfo+=n$CACHEDIR/vim/viminfo
    endif
endif

" If we're in a git project, determine the project root
let s:project_root = system('git rev-parse --show-toplevel 2> /dev/null')

" If we're in a git project and there's a node_modules/.bin in the project
" root, add it to the beginning of the path so that it's apps will be used for
" commands started by vim.
if !empty(s:project_root)
    let s:project_root = substitute(s:project_root, '\n\+$', '', '')
    let bindir = s:project_root . '/node_modules/.bin'
    if !empty(glob(bindir))
        let $PATH = bindir . ':' . $PATH
    endif
endif

" General options --------------------------------------------------------------

set backupcopy=yes           " Overwrite the original file when saving
set breakindent              " When lines are broken by linebreak, maintain indent
set cmdheight=2              " Keep vim from saying 'Press Enter to continue'
set undofile                 " Use undo files for persistent undo
set fillchars+=vert:\│       " Make the vertical split bar solid
set hidden                   " Use hidden buffers
set ignorecase               " Ignore case when searching...
set smartcase                " ...unless the search is mixed case
set nojoinspaces             " Only insert 1 space after a period when joining lines
set nostartofline            " Don't move to the beginning of a line when jumping
set number                   " Show line numbers
set scrolloff=5              " Give the cursor a 5 line margin when scrolling
set shiftwidth=4             " Indent in 4-character wide chunks
set shortmess+=c             " Don't give ins-completion-menu messages
set showcmd                  " Show commands in the cmd area
set signcolumn=yes           " Always show sign column
set splitbelow               " New horiz split is below
set splitright               " New vert split is to the right
set tabstop=4                " Tabs are only 4 characters wide
set formatoptions+=ron       " Automatically format comments and numbered lists
set ruler                    " Show location info in statusline
set nowrap                   " Don't wrap text by default
set wildignorecase           " Case insensitive filename completion
set lazyredraw               " Redraw less frequently
set updatetime=100           " More responsive UI updates
set noshowmode               " Don't show the mode on the last line

" Show markers at the beginning and end of non-wrapped lines
set listchars+=precedes:^,extends:$

" Ignore binary files in the standard vim file finder
set wildignore+=*.pyc,*.obj,*.bin,a.out

" Change the shape of the cursor based on VIM's mode
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
    \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
    \,sm:block-blinkwait175-blinkoff150-blinkon175

" Set the version of python used for pyx commands
if has('pythonx')
    set pyxversion=3
endif

" Enable truecolor mode in supporting terminals
if $TERM_PROGRAM == 'iTerm.app' || $TERM_PROGRAM == 'kitty' || $TERM_PROGRAM == 'alacritty'
    if !has('nvi')
        set t_8f=[38;2;%lu;%lu;%lum
        set t_8b=[48;2;%lu;%lu;%lum
    endif
    set termguicolors
endif

if has('nvim')
    " Better diff
    set diffopt+=internal,algorithm:patience
endif

" Ripgrep or ag for grepping
if executable('rg')
    set grepprg=rg\ --no-heading\ --color=never
elseif executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
endif

" Mappings ---------------------------------------------------------------------

" ; for leader commands
let mapleader=';'

" # to toggle cursor crosshairs
map <silent> # :set cursorcolumn! cursorline!<CR>

" Y to yank to the clipboard
map <silent> Y "*y

" <Leader>w to write
map <silent> <Leader>w :w<CR>
map <silent> <Leader>W :w!<CR>

" <Leader>q to quit
map <silent> <Leader>q :qall<CR>
map <silent> <Leader>Q :qall!<CR>

" <Leader>c to close a window
map <silent> <Leader>c :close<CR>

" <Leader>k to kill a buffer (Bd comes from vim-bbye)
map <silent> <Leader>k :Bd<CR>
map <silent> <Leader>K :bd!<CR>

" <Leader>h to show the syntax highlight status of the character under the
" cursor
map <silent> <Leader>h :echo "hi<" . 
    \ synIDattr(synID(line("."),col("."),1),"name") 
    \ . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" <Leader>f to find files
map <Leader>f :find 

" <Leader>b to list buffers
map <silent> <Leader>b :ls<CR> 

" Tab for cycling forwards through matches in a completion popup (taken
" from coc help)
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~# '\s'
endfunction
inoremap <silent><expr> <Tab>
    \ pumvisible() ? "\<C-n>" :
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
    else
        call CocAction('doHover')
    endif
endfunction
nnoremap <silent> K :call <SID>show_documentation()<CR>

" space to clear search highlights
noremap <silent> <space> :noh<cr>

" Autocommands -----------------------------------------------------------------

" Easier navigation of text files (used in autocommands)
function! TextMode()
    setlocal wrap linebreak nolist display+=lastline
    map <buffer> <silent> k gk
    map <buffer> <silent> j gj
    map <buffer> <silent> 0 g0
    map <buffer> <silent> $ g$
endfunction

" General autocommands
augroup vimrc
    " Make text files easier to work with
    autocmd FileType text call TextMode()
    autocmd FileType textile call TextMode()
    autocmd FileType markdown call TextMode()
    autocmd FileType html call TextMode()

    " If vim is resized, resize any splits
    autocmd VimResized * wincmd =

    " Wrap lines in quickfix windows
    autocmd FileType qf setlocal wrap linebreak nolist breakindent breakindentopt=shift:2

    " Always start at the top of git commit messages
    autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])

    " Close help files and quickfix panes on 'q' or Escape
    autocmd FileType help nnoremap <buffer> <silent> q :bd<CR>
    autocmd FileType qf nnoremap <buffer> <silent> q :bd<CR>
    autocmd BufEnter output:///info nnoremap <buffer> <silent> q :bd<CR>

    " More predictable syntax highlighting
    autocmd BufEnter * syntax sync fromstart

    " Automatically close preview windows after autocompletion
    autocmd CompleteDone * pclose

    " Identify files in a zsh/functions directory as zsh scripts
    autocmd BufRead */zsh/functions/* set filetype=zsh

    " ejs is HTML
    autocmd BufRead *.ejs set filetype=html

    " intern.json is jsonc
    autocmd BufRead intern.json,tsconfig.json set filetype=jsonc

    " When editing a file, jump back to the last edited line if it makes sense
    " to do so
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \     execute "normal! g'\"" |
        \ endif

    " move line mappings
    " ∆ is <A-j> on macOS
    " ˚ is <A-k> on macOS
    nnoremap ∆ :m .+1<cr>==
    nnoremap ˚ :m .-2<cr>==
    inoremap ∆ <Esc>:m .+1<cr>==gi
    inoremap ˚ <Esc>:m .-2<cr>==gi
    vnoremap ∆ :m '>+1<cr>gv=gv
    vnoremap ˚ :m '<-2<cr>gv=gv

    " Use ;; to go to previous buffer
    nnoremap <leader><leader> <C-^>
augroup END

" Setup a Tig command that opens tig in a terminal
if executable('tig') && has('nvim')
    command! Tig Term 'tig'
endif

" Setup 'A' for Angular files
function! s:AngularAlternate()
    let l:current_base = expand('%:r')
    let l:possible_files = glob(l:current_base . '.{ts,html}', 0, 1)
    if len(l:possible_files) > 1
        let l:current_file = expand('%')
        let l:current_index = index(l:possible_files, l:current_file)
        let l:next_index = (l:current_index + 1) % len(l:possible_files)
        execute('e ' . l:possible_files[l:next_index])
    endif
endfunction

augroup vimrc
    autocmd FileType typescript,html,css command! -buffer AngularAlternate :call s:AngularAlternate()
    autocmd FileType typescript,html,css nnoremap <silent><buffer> A :AngularAlternate<CR>
augroup END

" =====================================================================
" Plugin config
" =====================================================================

" Base16
" ---------------------------------------------------------------------
function! s:base16_load_theme()
    if filereadable(expand("~/.vimrc_background"))
      let base16colorspace=256
      source ~/.vimrc_background
    endif
endfunction

command! UpdateColors call s:base16_load_theme()

function! s:base16_customize()
    hi Normal guibg=NONE ctermbg=NONE
    hi Comment gui=italic
    exec 'hi Visual guibg=#' . g:base16_gui02 . ' ctermbg=2'
        \ . ' guifg=#' . g:base16_gui00 . ' ctermfg=0'
    exec 'hi MatchParen guibg=#' . g:base16_gui02 . ' ctermbg=2'
        \ . ' guifg=#' . g:base16_gui01  . ' ctermfg=1'
    exec 'hi MatchParenCur guibg=#' . g:base16_gui03 . ' ctermbg=3'
        \ . ' guifg=#' . g:base16_gui00  . ' ctermfg=0'

    " This doesn't currently work
    " see https://github.com/neovim/neovim/issues/7018
    if has('nvim')
        let g:terminal_color_16 = '#' . g:base16_gui09
        let g:terminal_color_17 = '#' . g:base16_gui0F
        let g:terminal_color_18 = '#' . g:base16_gui01
        let g:terminal_color_19 = '#' . g:base16_gui02
        let g:terminal_color_20 = '#' . g:base16_gui04
        let g:terminal_color_21 = '#' . g:base16_gui06
    endif
endfunction

augroup vimrc
    autocmd ColorScheme * call s:base16_customize()
augroup END

" coc
" ---------------------------------------------------------------------
augroup vimrc
    autocmd FileType typescript,javascript,python,html,go,c,sh map <buffer> <silent> <C-]> <Plug>(coc-definition)
    autocmd FileType typescript,javascript,python,go,c,sh map <buffer> <silent> <leader>r <Plug>(coc-rename)
    autocmd FileType typescript,javascript,python,go,c,sh map <buffer> <silent> <leader>j <Plug>(coc-references)
    autocmd FileType typescript,javascript,python,go,c,sh map <buffer> <silent> <leader>t <Plug>(coc-format-selected)
    autocmd CursorHold * silent call CocActionAsync('highlight')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END

map <silent> <Leader>e :CocList diagnostics<cr>
map <silent> <Leader>l :CocList<CR>
map <silent> <Leader>x <Plug>(coc-codeaction)
map <silent> <Leader>p <Plug>(coc-format-selected)

" navigate chunks of current buffer

nmap ]g <Plug>(coc-git-nextchunk)
" show chunk diff at current position
nmap gs <Plug>(coc-git-chunkinfo)
" show commit contains current position
nmap gl <Plug>(coc-git-commit)
nmap gf :CocCommand git.foldUnchanged<CR>

command! -nargs=0 OrganizeImports :CocCommand editor.action.organizeImport
command! -nargs=0 Prettier :CocCommand prettier.formatFile
command! -nargs=0 Format :call CocAction('format')

nnoremap <expr><C-f> coc#util#has_float() ? coc#util#float_scroll(1) : "\<C-f>"
nnoremap <expr><C-b> coc#util#has_float() ? coc#util#float_scroll(0) : "\<C-b>"

" A COC_NODE_PATH env var points to the version of node that should be used by
" the vim session (particularly coc). Use it to set g:coc_node_path and to
" update the PATH for this vim session. At least coc-sh only works with Node
" 10.
let g:coc_node_path = expand('~/.nodenv/versions/10.16.2/bin/node')
if !empty($COC_NODE_PATH)
    let g:coc_node_path = $COC_NODE_PATH . '/bin/node'
    let $PATH = $COC_NODE_PATH . '/bin:' . $PATH
endif

let g:coc_global_extensions = [
    \ 'coc-angular',
    \ 'coc-calc',
    \ 'coc-css',
    \ 'coc-emmet',
    \ 'coc-emoji',
    \ 'coc-git',
    \ 'coc-github',
    \ 'coc-java',
    \ 'coc-json',
    \ 'coc-lists',
    \ 'coc-pairs',
    \ 'coc-python',
    \ 'coc-rls',
    \ 'coc-sh',
    \ 'coc-svg',
    \ 'coc-tslint-plugin',
    \ 'coc-tsserver',
    \ 'coc-vimlsp',
    \ 'coc-vimtex',
    \ 'coc-yaml',
    \ 'coc-xml',
    \ 'coc-eslint',
    \ 'coc-jest',
    \ 'coc-highlight',
    \ 'coc-prettier',
    \ ]

let g:coc_status_error_sign = ' '
let g:coc_status_warning_sign = ' '

function! s:coc_customize_colors()
    exec 'hi CocErrorSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui08 . ' gui=bold'
    exec 'hi CocErrorVirtualText guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui08 . ' gui=NONE'
    exec 'hi CocWarningSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0A . ' gui=bold'
    exec 'hi CocWarningVirtualText guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0A . ' gui=NONE'
    exec 'hi CocInfoSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0B . ' gui=bold'
    exec 'hi CocInfoVirtualText guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0B . ' gui=NONE'
endfunction

augroup vimrc
    autocmd ColorScheme * call s:coc_customize_colors()
augroup END

" EasyAlign
" ---------------------------------------------------------------------
" To align end-of-line comments, do <Leader>a-<space>
map <silent> <Leader>a <Plug>(EasyAlign)

" Go
" ---------------------------------------------------------------------
let g:go_fmt_command = 'goimports'
let g:go_fmt_fail_silently = 1
let g:go_metalinter_excludes = ['errcheck']

" JavaScript
" ---------------------------------------------------------------------
let g:html_indent_script1 = 'inc'
let g:html_indent_style1 = 'inc'
let g:js_indent_flat_switch = 1

" lightline
" ---------------------------------------------------------------------
let g:lightline = {
    \ 'colorscheme': 'base16',
    \ 'active': {
    \   'left': [
    \     [ 'mode', 'paste' ],
    \     [ 'gitbranch' ],
    \     [ 'readonly', 'filename' ]
    \   ],
    \   'right': [
    \     [ 'lineinfo', 'percent' ],
    \     [ 'cocstatus', 'sleuth' ],
    \     [ 'gitblame', 'filetype', 'fileformat', 'fileencoding' ]
    \   ]
    \ },
    \ 'component': {
    \   'lineinfo': '%l:%v',
    \   'percent': '%p%%'
    \ },
    \ 'component_type': {
    \   'readonly': 'error',
    \ },
    \ 'component_function': {
    \   'cocstatus': 'coc#status',
    \   'currentfunction': 'CocCurrentFunction',
    \   'fileencoding': 'LightlineFileEncoding',
    \   'filename': 'LightlineFileName',
    \   'fileformat': 'LightlineFileFormat',
    \   'filetype': 'LightlineFileType',
    \   'gitbranch': 'LightlineGitBranch',
    \   'gitblame': 'LightlineGitBlame',
    \   'sleuth': 'SleuthIndicator'
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '', 'right': '' },
    \ 'enable': {
    \   'tabline': 0
    \ }
    \ }

function! LightlineFileName() abort
    let filename = winwidth(0) > 70 ? expand('%') : expand('%:t')
    if filename =~ 'NERD_tree'
        return ''
    endif
    let modified = &modified ? ' +' : ''
    return fnamemodify(filename, ":~:.") . modified
endfunction

function! LightlineFileEncoding()
    return &fileencoding == 'utf-8' ? '' : &fileencoding
endfunction

function! LightlineFileFormat()
    return WebDevIconsGetFileFormatSymbol()
endfunction

function! LightlineFileType()
    return WebDevIconsGetFileTypeSymbol()
endfunction

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

function! s:lightline_update()
    if !exists('g:loaded_lightline')
        return
    endif
    try
        call lightline#colorscheme#base16#refresh()
        call lightline#init()
        call lightline#update()
    catch
    endtry
endfunction

augroup vimrc
    autocmd ColorScheme * call s:lightline_update()
augroup END

" NERDTree
" ---------------------------------------------------------------------
let g:NERDTreeAutoDeleteBuffer=1
let g:NERDTreeMinimalUI=1
let g:NERDTreeWinSize=40
let g:NERDTreeRespectWildIgnore = 1
let g:NERDTreeDirArrowExpandable = "\u00a0" " make arrows invisible
let g:NERDTreeDirArrowCollapsible = "\u00a0" " make arrows invisible

function! ToggleNerdTree()
    if @% !=# '' && (!exists('g:NERDTree') || (g:NERDTree.ExistsForTab() && !g:NERDTree.IsOpen()))
        :NERDTreeFind
    else 
        :NERDTreeToggle
    endif
endfunction

map <silent> <Leader>n :call ToggleNerdTree()<CR>

" neovim
" ---------------------------------------------------------------------
if has('nvim')
    set inccommand=nosplit       " Show live substitutions

    " <Leader>e to escape into command mode in an nvim terminal
    tnoremap <leader>e <C-\><C-n>

    function! s:closeTerminal(job_id, code, event) dict
        close
    endfun

    function! s:openTerminal(...)
        let l:cmd = empty(a:1) ? $SHELL : a:1
        new
        set nonumber
        call termopen(l:cmd, { 'on_exit': function('s:closeTerminal') })
        startinsert
    endfunction

    command! -nargs=? Term call s:openTerminal("<args>")

    " Tell Neovim.app which Python to use
    if executable('/usr/local/bin/python2')
        let g:python_host_prog='/usr/local/bin/python2'
    endif
    if executable('/usr/local/bin/python3')
        let g:python3_host_prog='/usr/local/bin/python3'
    endif

    " Note -- Don't enable termguicolors because it's all around better for
    " neovim to use the existing terminal palette rather than managing its
    " own. For example, when using the terminal palette we automatically get
    " things like tmux pane focus dimming.
endif

" startify
" --------------------------------------------------------------------- 
let g:startify_relative_path = 1
let g:startify_fortune_use_unicode = 1
let g:startify_use_env = 1
let g:startify_files_number = 5
let g:startify_change_to_dir = 0
" let g:startify_custom_header = []

function! StartifyShowCommit(commit)
    new
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nowrap
    setlocal nonumber
    setlocal filetype=git
    exec '$read !Git -C "' . s:project_root . '" show ' . a:commit
    " Jump to the first line
    normal 1G
    " Remove the first line, which will be empty
    normal dd
    " No more writes
    setlocal nomodifiable
    " q to exit the view
    nnoremap <buffer> <silent> q :close<CR>
endfunction

function! s:startify_commit_cmd(index, str)
    let text = matchstr(a:str, "\\s\\zs.*")
    let commit = matchstr(a:str, "^\\x\\+")
    return {'line': l:text, 'cmd': 'call StartifyShowCommit("' . l:commit . '")' }
endfunction

function! s:startify_list_commits()
    " Don't bother looking for commits if we're not in a git project
    if empty(s:project_root)
        return []
    endif

    let commits = systemlist(
        \ 'git -C "' . s:project_root
        \ . '" log --format=format:"%h %s <%an, %ar>" -n '
        \ . g:startify_files_number)
    return map(commits, function('s:startify_commit_cmd'))
endfunction

let g:startify_lists = [
    \ { 'header': ['    MRU ' . getcwd()], 'type': 'dir' },
    \ { 'header': ['    MRU'], 'type': 'files' },
    \ { 'header': ['    Commits'], 'type': function('s:startify_list_commits') }
    \ ]

" autocmd vimrc User StartifyReady setlocal cursorline

" undotree
" --------------------------------------------------------------------- 
nnoremap <Leader>u :UndotreeToggle<CR>

" vim-jsx
" ---------------------------------------------------------------------
let g:jsx_ext_required = 1

" vim-markdown
" ---------------------------------------------------------------------
let g:markdown_fenced_languages = [
    \ 'help',
    \ 'html',
    \ 'js=javascript',
    \ 'json',
    \ 'json5=javascript',
    \ 'jsx=javascript.jsx',
    \ 'python',
    \ 'sh',
    \ 'ts=typescript',
    \ 'tsx=typescript.tsx',
    \ 'vim',
    \ 'xml',
    \ ]

" vimtex
" ---------------------------------------------------------------------
let g:vimtex_indent_lists = [
    \ 'itemize',
    \ 'description',
    \ 'enumerate',
    \ 'thebibliography',
    \ 'questions',
    \ 'answers',
    \ ]
let g:vimtex_indent_ignored_envs = [
    \ 'code',
    \ 'question',
    \ ]
let g:vimtex_compiler_progname = 'nvr'

" Plugins
" ---------------------------------------------------------------------
call plug#begin('~/.local/share/vim/plugins')

Plug 'andymass/vim-matchup'           " Better start/end matching
Plug 'sgur/vim-editorconfig'          " EditorConfig
Plug 'mhinz/vim-startify'             " Useful startup text
Plug 'tpope/vim-commentary'           " gc for commenting code blocks
Plug 'tpope/vim-eunuch'               " POSIX command wrappers
Plug 'tpope/vim-sleuth'               " Setup buffer options based on content
Plug 'tpope/vim-fugitive'             " Git utilities
Plug 'tpope/vim-unimpaired'           " useful pairs of mappings
Plug 'tpope/vim-repeat'               " support for repeating mapped commands
Plug 'tpope/vim-surround'             " for manipulating parens and such
Plug 'junegunn/gv.vim'                " a git commit browser
Plug 'moll/vim-bbye'                  " Preserve layout when closing buffers
Plug 'christoomey/vim-tmux-navigator' " Easy movement between vim and tmux panes
Plug 'junegunn/vim-easy-align'        " Easy vertical alignment of code elements
Plug 'mbbill/undotree'                " Visualize the undo tree
Plug 'jremmen/vim-ripgrep'            " RipGrep for file searching
Plug 'itchyny/lightline.vim'          " Flashy status bar
Plug 'chriskempson/base16-vim'        " Color schemes

 " Show version info in package.json files
Plug 'meain/vim-package-json', {
    \ 'do': 'cd rplugin/node/vim-package-json && npm install'
    \ }

" Completion
Plug 'neoclide/coc.nvim', {
    \ 'do': 'yarn install --frozen-lockfile'
    \ }

" File browsing
Plug 'scrooloose/nerdtree', {
    \ 'on': [ 'NERDTreeToggle', 'NERDTreeFind' ]
    \ }
Plug 'Xuyuanp/nerdtree-git-plugin', {
    \ 'on': [ 'NERDTreeToggle', 'NERDTreeFind' ]
    \ }
Plug 'jason0x43/vim-wildgitignore'

" Base filetype plugins (these detect filetypes)
Plug 'pangloss/vim-javascript'
Plug 'neoclide/jsonc.vim'
Plug 'mxw/vim-jsx'
Plug 'digitaltoad/vim-jade'
Plug 'keith/swift.vim'
Plug 'leafgarland/typescript-vim'
Plug 'ianks/vim-tsx'
Plug 'groenewege/vim-less'
Plug 'rust-lang/rust.vim'
Plug 'tpope/vim-markdown'
Plug 'wavded/vim-stylus'

" Filetype plugins (these provide filetype specific functionality, but don't
" themselves detect filetypes)
Plug 'vim-scripts/applescript.vim', {
    \ 'for': 'applescript'
    \ }
Plug 'vim-scripts/Textile-for-VIM', {
    \ 'for': 'textile'
    \ }
Plug 'mzlogin/vim-markdown-toc', {
    \ 'for': 'markdown'
    \ }
Plug 'tpope/vim-classpath', {
    \ 'for': 'java'
    \ }
Plug 'lervag/vimtex', {
    \ 'for': ['tex', 'latex']
    \ }

" Load the fzf plugin if fzf is available
if executable('fzf') && has('nvim')
    " Need to include both the plugin in fzf itself and the standalone plugin
    Plug $FZF_PATH
    Plug 'junegunn/fzf.vim'

    " Override the default files and buffers mappings with fzf ones
    map <silent> <Leader>f :Files<CR>
    map <silent> <Leader>b :Buffers<CR>
    " Show untracked files, too
    map <silent> <Leader>g :GFiles --cached --others --exclude-standard<CR>
    map <silent> <Leader>m :GFiles?<CR>

    let g:fzf_layout = { 'down': 10 }
endif

" Load devicons near the end so it can integrate with everything it needs to
Plug 'ryanoasis/vim-devicons'
Plug 'vwxyutarooo/nerdtree-devicons-syntax'

" Load all the plugins
call plug#end()

" Post-plugin initialization
call coc#config('session.directory', expand('$CACHEDIR') . '/vim/sessions')

UpdateColors
