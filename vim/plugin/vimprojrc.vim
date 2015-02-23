" Name:    vimprojrc.vim
" Version: 0.1
" Author:  Jason Cheatham <j.cheatham@gmail.com>
" Summary: Load settings from a project-level config file.
"
" The script searches for a .vimprojrc file, starting at the directory of the
" file being edited (or cwd), and searching up through the directory's
" parentage. It stops when a .vimprojrc file is found, or when it runs out of
" directories.
" 
" This script is heavily based on Markus Fischer's vimprojectrc.vim.

" only load this script once
if exists("g:loaded_vimprojrc")
	finish
endif
let g:loaded_vimprojrc = 1

" allow the user to set the name of the vimprojrc file
if !exists("g:vimprojrc_name")
	let s:vimprojrc_name = ".vimprojrc"
else
	let s:vimprojrc_name = g:vimprojrc_name
endif

" allow the user to enable sandbox mode for the project vimrc
if !exists("g:vimprojrc_use_sandbox")
	let s:vimprojrc_use_sandbox = 0
else
	let s:vimprojrc_use_sandbox = g:vimprojrc_use_sandbox
endif

" stuff to run when files are opened or created
if has("autocmd")
	augroup vimprojrc
		autocmd!

		" set type of .vimprojrc to 'vim'
		autocmd BufRead * call s:check_if_vimprojrc(expand("<amatch>:t"))

		" check for .vimprojrc file on every file open or buffer creation
		autocmd VimEnter,BufNewFile,BufRead * call s:load_vimprojrc()
	augroup END
endif

" if file is a vimprojrc file, set its type to 'vim'
function! s:check_if_vimprojrc(path)
	if a:path == s:vimprojrc_name
		set filetype=vim
	endif
endfunction

" load the first relevant vimprojrc file
function! s:load_vimprojrc()
	" skip non-file buffers
	if &buftype != ""
		return
	endif

	" get the directory of the current file
	let l:directory = fnameescape(expand("%:p:h"))
	if empty(l:directory)
		let l:directory = fnameescape(getcwd())
	endif

	" generate a list of all project rc files from here to $HOME
	let l:answer = ""
	let l:rcfile = findfile(s:vimprojrc_name, l:directory . ";")
	if filereadable(l:rcfile)
		let l:command = "silent "

		if s:vimprojrc_use_sandbox != 0
			let l:command .= "sandbox "
		endif

		let l:command .= "source " . fnameescape(l:rcfile)

		exec l:command
		"echom "vimprojrc: sourced file " . fnameescape(l:rcfile)

		redraw!
	endif
endfunction
