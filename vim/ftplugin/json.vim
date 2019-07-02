setlocal expandtab
setlocal shiftwidth=4

let fname = expand('%:t')
if fname ==? 'intern.json' || fname ==? 'tsconfig.json' || fname ==? 'coc-settings.json'
	setlocal commentstring=//\ %s
endif
