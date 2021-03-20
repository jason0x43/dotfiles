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
        set viminfo+=$CACHEDIR/vim/viminfo
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

let g:node_host_prog = '$HOMEBREW_BASE/bin/neovim-node-host'

" Add VimConfig command for quick access to vim config 
command! VimConfig e ~/.vim/vimrc

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
set updatetime=500           " More responsive UI updates
set noshowmode               " Don't show the mode on the last line
set mouse=a                  " Enable mouse support

" Improve completion experience with completion-nvim
set completeopt=menuone,noinsert,noselect

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

" Enable truecolor mode
set termguicolors

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

" <Leader>w to write
map <silent> <Leader>w :w<CR>
map <silent> <Leader>W :w!<CR>

" <Leader>q to quit
map <silent> <Leader>q :qall<CR>
map <silent> <Leader>Q :qall!<CR>

" <Leader>c to close a window
map <silent> <Leader>c :close<CR>

" <Leader>k to kill a buffer without closing its window
map <silent> <Leader>k :Bdelete<CR>
map <silent> <Leader>K :Bdelete!<CR>

" <Leader>h to show the syntax highlight status of the character under the
" cursor
map <silent> <Leader>h :echo "hi<" . 
    \ synIDattr(synID(line("."),col("."),1),"name") 
    \ . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Use tab to cycle through completions
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" space to clear search highlights
noremap <silent> <space> :noh<cr>

" yank to terminal
" https://sunaku.github.io/tmux-yank-osc52.html
function! Yank(text) abort
  let escape = system("term_copy", a:text)
  if v:shell_error
    echoerr escape
  else
    call writefile([escape], '/dev/tty', 'b')
  endif
endfunction

" yank to terminal and system clipboard
noremap <silent> <Leader>y y:<C-U>call Yank(@0)<CR>
" paste from system clipboard
noremap <silent> <Leader>p "*p


" Autocommands -----------------------------------------------------------------

" Easier navigation of text files (used in autocommands)
function! s:textMode()
    setlocal wrap linebreak nolist display+=lastline
    map <buffer> <silent> k gk
    map <buffer> <silent> j gj
    map <buffer> <silent> 0 g0
    map <buffer> <silent> $ g$
endfunction

function! s:showViewWidth()
    let &colorcolumn=join(range(81, 81+256), ",")
endfunction

" General autocommands
augroup vimrc
    " Make text files easier to work with
    autocmd FileType text call s:textMode()
    autocmd FileType textile call s:textMode()
    autocmd FileType markdown call s:textMode()
    autocmd FileType html call s:textMode()

	" Dim columns past 80
	autocmd BufEnter *.* call s:showViewWidth()

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

    " Auto-set quickfix height
    function! AdjustWindowHeight(minheight, maxheight)
      exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
    endfunction
    autocmd FileType qf call AdjustWindowHeight(1, 10)
augroup END

" Add a fullscreen Help command
command! -nargs=? -complete=help Help help <args> | only

" Setup a Tig command that opens tig in a terminal
if executable('tig') && has('nvim')
    command! Tig Term 'tig'
endif

" Setup a Lg command that opens lazygit in a terminal
if executable('lazygit') && has('nvim')
    command! Lg Term 'lazygit'
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

" Restore cursor position
function! s:restoreCursor()
  if &filetype == 'gitcommit' || &buftype == 'nofile'
    return
  endif

  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

autocmd vimrc BufWinEnter * call s:restoreCursor()

let s:hidden_all = 0
function! s:toggleChrome()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set cmdheight=1
        set laststatus=0
        set noshowcmd
        set nonumber
        set signcolumn=no
    else
        let s:hidden_all = 0
        set showmode
        set cmdheight=2
        set ruler
        set laststatus=2
        set showcmd
        set number
        set signcolumn=yes
    endif
endfunction
command! ToggleChrome call s:toggleChrome()

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
    exec 'hi Visual guibg=#' . g:base16_gui02
        \ . ' guifg=#' . g:base16_gui00
    exec 'hi MatchParen guibg=#' . g:base16_gui02
        \ . ' guifg=#' . g:base16_gui01
    exec 'hi MatchParenCur guibg=#' . g:base16_gui03
        \ . ' guifg=#' . g:base16_gui00
    exec 'hi Search guibg=#' . g:base16_gui0D
        \ . ' guifg=#' . g:base16_gui00
    exec 'hi IncSearch guibg=#' . g:base16_gui0D
        \ . ' guifg=#' . g:base16_gui00
    exec 'hi IncSearch guibg=#' . g:base16_gui0D
        \ . ' guifg=#' . g:base16_gui00
    exec 'hi Error guibg=NONE guifg=#' . g:base16_gui0E
    " hi visibility cursor
    hi Cursor guibg=red
    " no background for diffs (it messes with floating windows)
    hi DiffAdded guibg=NONE
    hi DiffFile guibg=NONE
    hi DiffNewFile guibg=NONE
    hi DiffLine guibg=NONE
    hi DiffRemoved guibg=NONE
    exec 'hi SpellBad guifg=#' . g:base16_gui0E

    hi htmlItalic gui=italic guifg=NONE guibg=NONE
    hi htmlBold gui=bold guifg=NONE guibg=NONE
    hi htmlBoldItalic gui=italic,bold guifg=NONE guibg=NONE

    exec 'hi MatchParen guifg=NONE guibg=#' . g:base16_gui01
    exec 'hi MatchParenCur guifg=NONE guibg=#' . g:base16_gui01

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

    exec 'hi LspDiagnosticsWarning guibg=NONE guifg=#' . g:base16_gui0F . ' gui=italic'
    exec 'hi LspDiagnosticsWarningSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0F . ' gui=bold'
    exec 'hi LspDiagnosticsWarningFloating guibg=NONE guifg=#' . g:base16_gui0F
    exec 'hi LspDiagnosticsUnderlineWarning gui=undercurl guisp=#' . g:base16_gui0F

    exec 'hi LspDiagnosticsError guibg=NONE guifg=#' . g:base16_gui0E . ' gui=italic'
    exec 'hi LspDiagnosticsErrorSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0E . ' gui=bold'
    exec 'hi LspDiagnosticsErrorFloating guibg=NONE guifg=#' . g:base16_gui0E
    exec 'hi LspDiagnosticsUnderlineError gui=undercurl guisp=#' . g:base16_gui0E

    exec 'hi LspDiagnosticsHintSign guibg=#' . g:base16_gui01 . ' guifg=#' . g:base16_gui0B . ' gui=bold'
    exec 'hi LspDiagnosticsHint guibg=NONE guifg=#' . g:base16_gui02 . ' gui=italic'
    exec 'hi LspDiagnosticsHintFloating guibg=NONE guifg=#' . g:base16_gui0B
    exec 'hi LspDiagnosticsUnderlineHint gui=undercurl guisp=#' . g:base16_gui0B
endfunction

augroup vimrc
    autocmd ColorScheme * call s:base16_customize()
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
    \     [ 'sleuth' ],
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
    \   'fileencoding': 'LightlineFileEncoding',
    \   'filename': 'LightlineFileName',
    \   'fileformat': 'LightlineFileFormat',
    \   'filetype': 'LightlineFileType',
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
    if filename =~ 'coc-explorer'
        return ''
    endif
    let modified = &modified ? ' +' : ''
    return fnamemodify(filename, ":~:.") . modified
endfunction

function! LightlineFileEncoding()
    return &fileencoding == 'utf-8' ? '' : &fileencoding
endfunction

function! LightlineFileFormat()
    let sym = WebDevIconsGetFileFormatSymbol()
    return !empty(sym) ? (sym . ' ') : ''
endfunction

function! LightlineFileType()
    return WebDevIconsGetFileTypeSymbol()
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
    if executable(expand('$HOMEBREW_BASE/bin/python2'))
        let g:python_host_prog='$HOMEBREW_BASE/bin/python2'
    endif
    if executable(expand('$HOMEBREW_BASE/bin/python3'))
        let g:python3_host_prog='$HOMEBREW_BASE/bin/python3'
    endif
endif

" startify
" --------------------------------------------------------------------- 
let g:startify_relative_path = 1
let g:startify_fortune_use_unicode = 1
let g:startify_use_env = 1
let g:startify_files_number = 5
let g:startify_change_to_dir = 0
let g:startify_ascii_header_1 = [
 \ '                          _         ',
 \ '   ____  ___  ____ _   __(_)___ ___ ',
 \ '  / __ \/ _ \/ __ \ | / / / __ `__ \',
 \ ' / / / /  __/ /_/ / |/ / / / / / / /',
 \ '/_/ /_/\___/\____/|___/_/_/ /_/ /_/ ',
 \ '',
 \]
let g:startify_ascii_header_2 = [
 \ ' ____ ____ ____ ____ ____ ____ ',
 \ '||n |||e |||o |||v |||i |||m ||',
 \ '||__|||__|||__|||__|||__|||__||',
 \ '|/__\|/__\|/__\|/__\|/__\|/__\|',
 \ '',
 \]
let g:startify_custom_header = 'startify#pad(g:startify_ascii_header_2)'

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

nnoremap <Leader>s :Startify<CR>

" undotree
" --------------------------------------------------------------------- 
nnoremap <Leader>u :UndotreeToggle<CR>

" vim-jsx
" ---------------------------------------------------------------------
let g:jsx_ext_required = 1

" vim-markdown
" ---------------------------------------------------------------------
" TODO: use javascriptreact and typescriptreact
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
let g:markdown_syntax_conceal = 0
let g:markdown_minlines = 100

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
call plug#begin('$CACHEDIR/vim/plugins')

Plug 'andymass/vim-matchup'           " Better start/end matching
Plug 'sgur/vim-editorconfig'          " EditorConfig
Plug 'mhinz/vim-startify'             " Useful startup text
Plug 'tpope/vim-commentary'           " gc for commenting code blocks
Plug 'tpope/vim-eunuch'               " POSIX command wrappers
Plug 'tpope/vim-fugitive'             " Git utilities
Plug 'tpope/vim-unimpaired'           " useful pairs of mappings
Plug 'tpope/vim-repeat'               " support for repeating mapped commands
Plug 'tpope/vim-surround'             " for manipulating parens and such
Plug 'moll/vim-bbye'                  " Preserve layout when closing buffers
Plug 'junegunn/vim-easy-align'        " Easy vertical alignment of code elements
Plug 'mbbill/undotree'                " Visualize the undo tree
Plug 'jremmen/vim-ripgrep'            " RipGrep for file searching
Plug 'itchyny/lightline.vim'          " Flashy status bar
Plug 'chriskempson/base16-vim'        " Color schemes
Plug 'powerman/vim-plugin-AnsiEsc'    " Render ANSI escape sequences

if exists('$TMUX')
    Plug 'christoomey/vim-tmux-navigator' " Easy movement between vim and tmux panes
else
    Plug 'knubie/vim-kitty-navigator'     " Easy movement between vim and kitty panes
endif

" Show version info in package.json files
Plug 'meain/vim-package-info', { 'do': 'npm install' }

" Base filetype plugins (these detect filetypes)
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/jsonc.vim'

" Completion
Plug 'neoclide/coc.nvim', {
    \ 'do': 'yarn install --frozen-lockfile'
    \ }

if has('nvim')
  let g:cursorhold_updatetime = 100
  Plug 'antoinemadec/FixCursorHold.nvim'
endif

if has('nvim-0.5')
    " nvim LSP
    " Plug 'neovim/nvim-lspconfig'
    " Plug 'nvim-lua/completion-nvim'
    " Plug 'nvim-lua/diagnostic-nvim'
    " Plug 'nvim-treesitter/completion-treesitter'

    " Flashier syntax highlighting
    Plug 'nvim-treesitter/nvim-treesitter'
endif

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
  runtime! init-fzf.vim
endif

" Load devicons near the end so it can integrate with everything it needs to
Plug 'ryanoasis/vim-devicons'

" Load all the plugins
call plug#end()

if has('nvim-0.5')
  lua require("treesitter_config")
endif 
