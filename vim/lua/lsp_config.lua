local map = function(type, key, value)
	vim.fn.nvim_buf_set_keymap(0, type, key, value, {noremap=true, silent=true})
end

local sign = function(name, symbol, hlgroup)
	vim.fn.sign_define(name, {text=symbol, texthl=hlgroup or name})
end

local custom_attach = function(client)
	require'completion'.on_attach(client)
	require'diagnostic'.on_attach(client)
end

local lsp = require'nvim_lsp'
lsp.tsserver.setup{on_attach = custom_attach}
lsp.vimls.setup{on_attach = custom_attach}
lsp.yamlls.setup{on_attach = custom_attach}
lsp.sourcekit.setup{on_attach = custom_attach}
lsp.diagnosticls.setup{
	on_attach = custom_attach,
	filetypes = { 'python' },
	init_options = {
		linters = {
			mypy = {
				sourceName = 'mypy',
				command = 'mypy',
				args = {
					'--no-color-output',
					'--no-error-summary',
					'--show-column-numbers',
					'--follow-imports=silent',
					'--shadow-file',
					'%filepath',
					'%tempfile',
					'%filepath'
				},
				formatPattern = {
					'^.*?:(\\d+):(\\d+):\\s+([a-z]+?):\\s+(.*)$',
					{
						line = 1,
						column = 2,
						endLine = 1,
						endColumn = 2,
						security = 3,
						message = 4
					}
				},
				rootPatterns = { '.git', 'pyproject.toml', 'setup.py' },
				securities = {
					error = 'error'
				}
			},
			flake8 = {
				sourceName = 'flake8',
				command = 'flake8',
				args = { '--stdin-display-name', '%file', '%tempfile' },
				formatPattern = {
					'^.*?:(\\d+?):(\\d+?):\\s+(\\w)(.*)$',
					{
						line = 1,
						column = 2,
						security = 3,
						message = {3, 4}
					}
				},
				rootPatterns = { '.git', 'pyproject.toml', 'setup.py' },
				securities = {
					W = 'warning',
					F = 'hint',
					E = 'error',
				},
				offsetColumn = 1,
				formatLines = 1
			},
			pylint = {
				sourceName = 'pylint',
				command = 'pylint',
				args = {
					'--output-format',
					'text',
					'--score',
					'no',
					'--msg-template',
					'"{line}:{column}:{category}:{msg} ({msg_id}:{symbol})"',
					'%file'
				},
				formatPattern = {
					'^(\\d+?):(\\d+?):([a-z]+?):(.*)$',
					{
						line = 1,
						column = 2,
						security = 3,
						message = 4
					}
				},
				rootPatterns = { '.git', 'pyproject.toml', 'setup.py' },
				securities = {
					informational = 'hint',
					refactor = 'info',
					convention = 'info',
					warning = 'warning',
					error = 'error',
					fatal = 'error'
				},
				offsetColumn = 1,
				formatLines = 1
			}
		},
		formatters = {
			black = {
				command = 'black',
				args = { '-q', '-' },
				rootPatterns = {'.git', 'pyproject.toml', 'setup.py'},
			}
		},
		filetypes = {
			python = {'mypy', 'flake8'}
		},
		formatFiletypes = {
			python = {'black'}
		}
	}
}
lsp.jedi_language_server.setup{on_attach = custom_attach}
-- Lsp.pyls.setup{
-- 	on_attach = custom_attach,
-- 	settings = {
-- 		pyls = {
-- 			plugins = {
-- 				pyls_mypy = { enabled = true },
-- 				pyls_isort = { enabled = true },
-- 				pyls_black = { enabled = true },
-- 				pycodestyle = { enabled = false },
-- 			}
-- 		}
-- 	}
-- }
lsp.sumneko_lua.setup{
	on_attach = custom_attach,
	settings = {
		Lua = {
			diagnostics = {
				enable = true,
				globals = {
					"vim", "describe", "it", "before_each", "after_each"
				}
			}
		}
	}
}

map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<leader>e', '<cmd>OpenDiagnostic<CR>')
map('n', '<leader>d', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>')
map('n', '<leader>j', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<CR>')

sign('LspDiagnosticsHintSign', '')
sign('LspDiagnosticsErrorSign', '')
sign('LspDiagnosticsWarningSign', '')

-- vim.g.diagnostic_enable_virtual_text = 1
-- vim.g.diagnostic_virtual_text_prefix = ' '
