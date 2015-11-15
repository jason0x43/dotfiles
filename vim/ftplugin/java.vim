if filereadable("pom.xml")
	let g:neomake_java_maven_maker = {
		\ 'exe': 'mvn',
		\ 'args': ['-q', 'compile'],
		\ 'append_file': 0,
		\ 'errorformat': '[ERROR] %f:[%l\,%c] error: %m'
		\ }

	let g:neomake_java_enabled_makers = ['maven']
endif
