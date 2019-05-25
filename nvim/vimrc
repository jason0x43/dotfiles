scriptencoding utf8

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

    if !has('nvim')
        set viminfo+=n$CACHEDIR/vim/viminfo
    endif
endif

" If we're in a git project and there's a node_modules/.bin in the project
" root, add it to the beginning of the path so that it's apps will be used for
" commands started by vim. In particular this is useful for YCM + TypeScript
" since YCM doesn't automatically look for a local TypeScript install.
let project_root=system('git rev-parse --show-toplevel 2> /dev/null')
if !empty(project_root)
    let project_root=substitute(project_root, '\n\+$', '', '')
    let bindir=project_root . '/node_modules/.bin'
    if !empty(glob(bindir))
        let $PATH=bindir . ':' . $PATH
    endif
endif

colorscheme base16
let mapleader=';'

set backupcopy=yes           " Overwrite the original file when saving
set breakindent              " When lines are broken by linebreak, maintain indent
set clipboard+=unnamed       " Yank to the system clipboard. 'unnamed' works in neovim _and_ MacVim
set cmdheight=2              " Keep vim from saying 'Press Enter to continue'
set undofile                 " Use undo files for persistent undo
set fillchars+=vert:\│       " Make the vertical split bar solid
set hidden                   " Use hidden buffers
set ignorecase               " Ignore case when searching...
set smartcase                " ...unless the search is mixed case
set nojoinspaces             " Only insert 1 space after a period when joining lines
set nostartofline            " Don't move to the beginning of a line when jumping
set number                   " Show line numbers
set completeopt+=noinsert
set completeopt+=menuone
set completeopt+=noselect
set scrolloff=5              " Give the cursor a 5 line margin when scrolling
set shiftwidth=4             " Indent in 4-character wide chunks
set showcmd                  " Show commands in the cmd area
set tabstop=4                " Tabs are only 4 characters wide
set formatoptions+=ron       " Automatically format comments and numbered lists
set ruler                    " Show location info in statusline
set nowrap                   " Don't wrap text by default
set wildignorecase           " Case insensitive filename completion
set lazyredraw               " Redraw less frequently
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
    \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
    \,sm:block-blinkwait175-blinkoff150-blinkon175
set updatetime=100           " More responsive UI updates

" Better diff
set diffopt+=internal,algorithm:patience

" Toggle cursor crosshairs
map <silent> # :set cursorcolumn! cursorline!<CR>

" Show markers at the beginning and end of non-wrapped lines
set listchars+=precedes:^,extends:$

" Ignore binary files in the standard vim file finder
set wildignore+=*.pyc,*.obj,*.bin,a.out

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

" <Leader>space to clear search highlights
map <silent> <Leader><Space> :nohlsearch<CR>

" Show the syntax status of the character under the cursor
map <silent> <Leader>h :echo "hi<" . 
    \ synIDattr(synID(line("."),col("."),1),"name") 
    \ . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Files and buffers
map <Leader>f :find 
map <silent> <Leader>b :ls<CR> 

" Use Tab for cycling through matches in a completion popup
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> (pumvisible() ? (!empty(v:completed_item) ? "\<c-y>" : "\<c-y>\<cr>") : "\<CR>")

" Ag for grepping (https://github.com/ggreer/the_silver_searcher)
if executable('rg')
    set grepprg=rg\ --no-heading\ --color=never
elseif executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
endif

" Better start/end atching
runtime! macros/matchit.vim

" Easier navigation of text files
function! TextMode()
    setlocal wrap linebreak nolist display+=lastline
    map <buffer> <silent> k gk
    map <buffer> <silent> j gj
    map <buffer> <silent> 0 g0
    map <buffer> <silent> $ g$
endfunction

" General autocommands
augroup vimrc
    autocmd!

    " Make text files easier to work with
    autocmd FileType text call TextMode()
    autocmd FileType textile call TextMode()
    autocmd FileType markdown call TextMode()
    autocmd FileType html call TextMode()

    " Wrap lines in quickfix windows
    autocmd FileType qf setlocal wrap linebreak nolist breakindent breakindentopt=shift:2

    " Always start at the top of git commit messages
    autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])

    " Close help files and quickfix panes on 'q' or Escape
    autocmd FileType help nnoremap <buffer> <silent> q :bd<CR>
    autocmd FileType qf nnoremap <buffer> <silent> q :bd<CR>

    " Can't do this because it breaks vim's standard go-to-tag
    " autocmd FileType help nnoremap <buffer> <silent>  :bd<CR>
    " autocmd FileType qf nnoremap <buffer> <silent>  :bd<CR>

    " More predictable syntax highlighting
    autocmd BufEnter * syntax sync fromstart

    " Automatically close preview windows after autocompletion
    autocmd CompleteDone * pclose

    " Identify files in a zsh/functions directory as zsh scripts
    autocmd BufRead */zsh/functions/* set filetype=zsh

    " ejs is HTML
    autocmd BufRead *.ejs set filetype=html

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
if has('nvim')
    function! s:tig()
        let s:callback = {}
        let current = expand('%')

        function! s:callback.on_exit(job_id, code, event)
            bw!
        endfunction

        below new
        call termopen('tig status', s:callback)
        startinsert
    endfunction

    command! Tig call s:tig()
endif


" =====================================================================
" Plugin config
" =====================================================================

" ALE
" ---------------------------------------------------------------------
let g:ale_linters = {
    \ 'typescript': ['tslint'],
    \ 'typescript.tsx': ['tslint'],
    \ 'php': [''],
    \ }
let g:ale_pattern_options = {
    \ 'node_modules/': { 'ale_enabled': 0 }
    \ }
let g:ale_completion_enabled = 0
" let g:ale_tex_chktex_options = "-I -x"
" map <Leader>e :lope<CR> 
" map <Leader>i :ALEHover<CR> 

" asyncomplete
" ---------------------------------------------------------------------
let g:asyncomplete_smart_completion = 1
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_remove_duplicates = 1

" EasyAlign
" ---------------------------------------------------------------------
" To align end-of-line comments, do <Leader>a-<space>
map <silent> <Leader>a <Plug>(EasyAlign)

" Flagship
" ---------------------------------------------------------------------
" Don't show the tabline when using Flagship
let g:tablabel=''

" fzf
" ---------------------------------------------------------------------
let g:fzf_layout = { 'down': 10 }

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

" json
" ---------------------------------------------------------------------
" Don't conceal quotes around JSON properties
let g:vim_json_syntax_conceal = 0

" markdown
" ---------------------------------------------------------------------
let g:markdown_fenced_languages = [
\    'html',
\    'python',
\    'sh',
\    'json',
\    'xml',
\    'json5=javascript',
\    'js=javascript',
\    'jsx=javascript.jsx',
\    'ts=typescript',
\    'tsx=typescript.tsx',
\ ]

" NERDTree
" ---------------------------------------------------------------------
let g:NERDTreeAutoDeleteBuffer=1
let g:NERDTreeMinimalUI=1
let g:NERDTreeWinSize=40
let g:NERDTreeRespectWildIgnore = 1

function! ToggleNerdTree()
    if @% !=# '' && (!exists('g:NERDTree') || (g:NERDTree.ExistsForTab() && !g:NERDTree.IsOpen()))
        :NERDTreeFind
    else 
        :NERDTreeToggle
    endif
endfunction

map <silent> <Leader>n :call ToggleNerdTree()<CR>

" Neovim
" ---------------------------------------------------------------------
if has('nvim')
    set inccommand=nosplit       " Show live substitutions

    " <Leader>e to escape into command mode in an nvim terminal
    tnoremap <leader>e <C-\><C-n>

    " Always enter insert mode when switching to a terminal
    autocmd vimrc BufWinEnter,WinEnter term://* startinsert

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

" Prettier
" ---------------------------------------------------------------------
let g:prettier#exec_cmd_async = 1
let g:prettier#config#parser = 'babylon'

" undotree
" --------------------------------------------------------------------- 
nnoremap <Leader>u :UndotreeToggle<CR>

" vim-autoprettier
" --------------------------------------------------------------------- 
let g:autoprettier_types = [
    \ 'typescript',
    \ 'typescript.tsx',
    \ 'javascript',
    \ 'javascript.jsx',
    \ 'json',
    \ 'jsoncfg',
    \ 'css',
    \ 'markdown',
    \ 'scss',
    \ ]
let g:autoprettier_exclude = [
    \ 'package.json',
    \ 'package-lock.json'
    \ ]

" vim-jsx
" ---------------------------------------------------------------------
let g:jsx_ext_required = 1

" vim-lsp
" ---------------------------------------------------------------------
" let g:lsp_log_verbose = 1
" let g:lsp_log_file = expand('~/vim-lsp.log')
let g:lsp_signs_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay = 100
let g:lsp_signs_error = {'text': '✗'}
let g:lsp_signs_warning = {'text': '!'}
let g:lsp_signs_information = {'text': '?'}
let g:lsp_signs_hint = {'text': '$'}

" vim-signify
" ---------------------------------------------------------------------
let g:signify_vcs_list = ['git']
let s:signify_sign = '┃'
let g:signify_sign_add = s:signify_sign
let g:signify_sign_change = s:signify_sign
let g:signify_sign_changedelete = s:signify_sign
let g:signify_sign_delete = s:signify_sign
let g:signify_sign_show_count = 10

" vimtex
" ---------------------------------------------------------------------
let g:vimtex_indent_lists = [
    \ 'itemize',
    \ 'description',
    \ 'enumerate',
    \ 'thebibliography',
    \ 'questions',
    \ 'answers',
    \]
let g:vimtex_indent_ignored_envs = [
    \ 'code',
    \ 'question',
    \]

" Plugins
" ---------------------------------------------------------------------
call plug#begin('~/.local/share/vim/plugins')

Plug 'sgur/vim-editorconfig'               " EditorConfig
Plug 'tpope/vim-commentary'                " gc for commenting code blocks
Plug 'tpope/vim-eunuch'                    " POSIX command wrappers
Plug 'tpope/vim-sleuth'                    " Setup buffer options based on content
Plug 'tpope/vim-flagship'                  " Status line configuration
Plug 'tpope/vim-fugitive'                  " Git utilities
Plug 'tpope/vim-unimpaired'                " useful pairs of mappings
Plug 'tpope/vim-repeat'                    " support for repeating mapped commands
Plug 'tpope/vim-surround'                  " for manipulating parens and such
Plug 'junegunn/gv.vim'                     " a git commit browser
Plug 'moll/vim-bbye'                       " Preserve layout when closing buffers
Plug 'christoomey/vim-tmux-navigator'      " Easy movement between vim and tmux panes
Plug 'junegunn/vim-easy-align'             " Easy vertical alignment of code elements
Plug 'mbbill/undotree'                     " Visualize the undo tree
Plug 'prettier/vim-prettier', { 'do': 'npm install' } " Format TS, JS, MD, and others
Plug 'jason0x43/vim-autoprettier'          " Automatically run Prettier
Plug 'jremmen/vim-ripgrep'                 " RipGrep for file searching
Plug 'w0rp/ale'                            " Linting
Plug 'mhinz/vim-signify'                   " Show modified lines
Plug 'RRethy/vim-hexokinase'               " Show color swatches

" LSP
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'

" Completion
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'

" File browsing
Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTreeToggle', 'NERDTreeFind' ] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': [ 'NERDTreeToggle', 'NERDTreeFind' ] }
Plug 'jason0x43/vim-wildgitignore'

" Session management
Plug 'tpope/vim-obsession'

" Base filetype plugins (these detect filetypes)
Plug 'pangloss/vim-javascript'
Plug 'elzr/vim-json'
Plug 'mxw/vim-jsx'
Plug 'digitaltoad/vim-jade'
Plug 'keith/swift.vim'
Plug 'leafgarland/typescript-vim'
Plug 'ianks/vim-tsx'
Plug 'dag/vim-fish'
Plug 'groenewege/vim-less'
Plug 'rust-lang/rust.vim'
Plug 'tpope/vim-markdown'
Plug 'wavded/vim-stylus'
Plug 'dmix/elvish.vim'
Plug 'vmchale/ion-vim'
Plug 'fatih/vim-go'

" Filetype plugins
Plug 'vim-scripts/applescript.vim', { 'for': 'applescript' }
Plug 'vim-scripts/Textile-for-VIM', { 'for': 'textile' }
Plug 'mzlogin/vim-markdown-toc', { 'for': 'markdown' }
Plug 'tpope/vim-classpath', { 'for': 'java' }
Plug 'lervag/vimtex', { 'for': ['tex', 'latex'] }

" Load the fzf plugin if fzf is available
if executable('fzf') && has('nvim')
    Plug $FZF_PATH
    Plug 'junegunn/fzf.vim'

    " These mappings depend on the FZF plugin being loaded
    map <silent> <Leader>f :Files<CR>
    map <silent> <Leader>b :Buffers<CR>
    " Show untracked files, too
    map <silent> <Leader>g :GFiles --cached --others --exclude-standard<CR>
    map <silent> <Leader>m :GFiles?<CR>
    map <silent> <Leader>s :Snippets<CR>
    map <silent> <Leader>l :BLines<CR>
endif

" Load all the plugins
call plug#end()

" =====================================================================
" Post-plugin initialization
" =====================================================================

" vim-lsp
" ---------------------------------------------------------------------
let s:asyncomplete_blacklist = []

if executable('typescript-language-server')
    let s:asyncomplete_blacklist += ['typescript']
    autocmd vimrc User lsp_setup call lsp#register_server({
        \ 'name': 'typescript-language-server',
        \ 'priority': 99,
        \ 'cmd': {
        \     server_info -> [&shell, &shellcmdflag, 'typescript-language-server --stdio']
        \ },
        \ 'root_uri': {
        \     server_info->lsp#utils#path_to_uri(
        \         lsp#utils#find_nearest_parent_file_directory(
        \             lsp#utils#get_buffer_path(),
        \             'tsconfig.json'
        \         )
        \     )
        \ },
        \ 'whitelist': ['typescript', 'typescript.tsx', 'javascript', 'javascript.jsx'],
        \ })
    autocmd vimrc FileType typescript map <buffer> <silent> <C-]> :LspDefinition<CR>
    autocmd vimrc FileType typescript map <buffer> <Leader>e :LspDocumentDiagnostics<CR>
    autocmd vimrc FileType typescript map <buffer> K :LspHover<CR>
    autocmd vimrc FileType typescript setlocal omnifunc=lsp#complete
endif

if executable('php-language-server.php')
    let s:asyncomplete_blacklist += ['php']
    autocmd vimrc User lsp_setup call lsp#register_server({
        \ 'name': 'php-language-server',
        \ 'priority': 99,
        \ 'cmd': {
        \     server_info -> ['php', expand('~/.composer/vendor/bin/php-language-server.php')]
        \ },
        \ 'whitelist': ['php'],
        \ })
    autocmd vimrc FileType php map <buffer> <silent> <C-]> :LspDefinition<CR>
    autocmd vimrc FileType php map <buffer> <Leader>e :LspDocumentDiagnostics<CR>
    autocmd vimrc FileType php map <buffer> K :LspHover<CR>
    autocmd vimrc FileType php setlocal omnifunc=lsp#complete
endif

if executable(expand('~/Applications/java-language-server/bin/launcher'))
    let s:asyncomplete_blacklist += ['java']
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'java-language-server',
        \ 'priority': 99,
        \ 'cmd': {
        \     server_info -> [
        \         expand('~/Applications/java-language-server/bin/launcher'),
        \         '--quiet',
        \     ]
        \ },
        \ 'whitelist': ['java'],
        \ })
    autocmd vimrc FileType java map <buffer> <silent> <C-]> :LspDefinition<CR>
    autocmd vimrc FileType java map <buffer> <Leader>e :LspDocumentDiagnostics<CR>
    autocmd vimrc FileType java map <buffer> K :LspHover<CR>
    autocmd vimrc FileType java setlocal omnifunc=lsp#complete
endif

" asyncomplete
" ---------------------------------------------------------------------
autocmd User asyncomplete_setup call asyncomplete#register_source(
    \ asyncomplete#sources#buffer#get_source_options({
    \     'name': 'buffer',
    \     'whitelist': ['*'],
    \     'blacklist': s:asyncomplete_blacklist,
    \     'priority': 9,
    \     'completor': function('asyncomplete#sources#buffer#completor')
    \ }))

autocmd vimrc User asyncomplete_setup call asyncomplete#register_source(
    \ asyncomplete#sources#file#get_source_options({
    \     'name': 'file',
    \     'whitelist': ['*'],
    \     'priority': 10,
    \     'completor': function('asyncomplete#sources#file#completor')
    \ }))
