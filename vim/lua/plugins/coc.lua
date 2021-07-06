local util = require('util')

-- Create a global namespace for the coc utilities
_G.coc = {}
local coc = _G.coc

-- Set the registry for VIM to make COC happy
vim.fn.setenv('npm_config_registry', 'https://registry.npmjs.org')

vim.g.coc_node_path = vim.fn.expand('$HOMEBREW_BASE/bin/node')

vim.fn['coc#config']('session.directory', util.data_home .. '/nvim/sessions')

if vim.g['fzf#vim#buffers'] == nil then
  -- find files
  util.keys.lmap('f', 'CocList files')

  -- find files in a git repo
  util.keys.lmap('g', 'CocList gfiles')

  -- to find modified files in a git repo
  util.keys.lmap('m', 'CocList gstatus')

  -- list buffers
  util.keys.lmap('b', 'CocList buffers')
end

-- When popup menu is visible, tab goes to next entry.
util.keys.imap('<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true })

-- Shift-Tab for cycling backwards through matches in a completion popup
util.keys.imap(
	'<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<C-h>"',
	{ expr = true }
)

-- Enter to confirm completion
util.keys.imap('<CR>', 'pumvisible() ? "\\<C-y>" : "\\<CR>"', { expr = true })

-- K to show documentation in a preview window
function coc.show_documentation()
	local filetype = vim.bo.filetype
	if filetype == 'vim' or filetype == 'help' then
		vim.cmd('execute "h " . expand("<cword>")')
	elseif vim.fn['CocAction'] then
		vim.fn['CocAction']('doHover')
	end
end

util.keys.map('K', ':lua require("plugins.coc").show_documentation()<cr>')

util.augroup('vimrc', {
	'User CocJumpPlaceholder call CocActionAsync("showSignatureHelp")',
	'CursorHold * silent call CocActionAsync("highlight")',
})

util.keys.map(
	'<C-f>',
	'coc#float#has_scroll() ? coc#float#scroll(1) : "\\<C-f>"',
	{ expr = true, nowait = true }
)
util.keys.map(
	'<C-b>',
	'coc#float#has_scroll() ? coc#float#scroll(0) : "\\<C-b>"',
	{ expr = true, nowait = true }
)

util.cmd('Rg', ':CocList --interactive grep<cr>')

util.keys.lmap('e', ':CocList diagnostics<cr>')
util.keys.lmap('l', ':CocList<cr>')
util.keys.lmap('x', '<Plug>(coc-codeaction)')

util.keys.map('<M-f>', '<Plug>(coc-format)')
util.keys.map('<C-]>', '<Plug>(coc-defintion)')
util.keys.lmap('t', '<Plug>(coc-format-selected)')
util.keys.lmap('r', '<Plug>(coc-rename)')
util.keys.lmap('j', '<Plug>(coc-references)')
util.keys.lmap('d', '<Plug>(coc-diagnostic-info')

-- navigate chunks of current buffer
util.keys.nmap('g[', '<Plug>(coc-git-prevchunk')
util.keys.nmap('g]', '<Plug>(coc-git-nextchunk')
-- show chunk diff at current position
util.keys.nmap('gi', '<Plug>(coc-git-chunkinfo')
-- show commit contains current position (don't use gc)
util.keys.nmap('gl', '<Plug>(coc-git-commit')
-- stage current chunk
util.keys.nmap('gu', ':CocCommand git.chunkStage<cr>')
-- undo current chunk
util.keys.nmap('g!', ':CocCommand git.chunkUndo<cr>')
-- fold everything but chunnks
util.keys.nmap('gf', ':CocCommand git.foldUnchanged<cr>')

util.cmd('OrganizeImports', '-nargs=0', ':CocCommand editor.action.organizeImport')
util.cmd('Prettier', '-nargs=0', ':CocCommand prettier.formatFile')
util.cmd('Format', '-nargs=0', ':call CocAction("format")')

vim.g.coc_global_extensions = {
  'coc-calc',
  'coc-css',
  'coc-emmet',
  'coc-emoji',
  'coc-eslint',
  'coc-explorer',
  'coc-git',
  'coc-github',
  'coc-highlight',
  'coc-java',
  'coc-jest',
  'coc-json',
  'coc-lists',
  'coc-lua',
  'coc-prettier',
  'coc-pyright',
  'coc-rls',
  'coc-sh',
  'coc-snippets',
  'coc-svg',
  'coc-tsserver',
  'coc-vimlsp',
  'coc-vimtex',
  'coc-xml',
  'coc-yaml',
}

vim.g.coc_status_error_sign = ' '
vim.g.coc_status_info_sign = ' '
vim.g.coc_status_hint_sign = ' '
vim.g.coc_status_warning_sign = ' '

vim.g.coc_snippet_next = '<tab>'
vim.g.coc_snippet_prev = '<S-tab>'
vim.g.coc_disable_startup_warning = 1

function coc.customize_colors()
	vim.fn.execute('hi CocErrorSign guibg=#' .. vim.g.base16_gui01 .. ' guifg=#' .. vim.g.base16_gui0F .. ' gui=bold')
	vim.fn.execute('hi CocErrorVirtualText guibg=#' .. vim.g.base16_gui01 .. ' guifg=#' .. vim.g.base16_gui0F .. ' gui=NONE')
	vim.fn.execute('hi CocErrorHighlight gui=undercurl guisp=#' .. vim.g.base16_gui0F)

	vim.fn.execute('hi CocWarningSign guibg=#' .. vim.g.base16_gui01 .. ' guifg=#' .. vim.g.base16_gui08 .. ' gui=bold')
	vim.fn.execute('hi CocWarningVirtualText guibg=#' .. vim.g.base16_gui01 .. ' guifg=#' .. vim.g.base16_gui08 .. ' gui=NONE')
	vim.fn.execute('hi CocWarningHighlight gui=undercurl guisp=#' .. vim.g.base16_gui08)

	vim.fn.execute('hi CocInfoSign guibg=#' .. vim.g.base16_gui01 .. ' guifg=#' .. vim.g.base16_gui0B .. ' gui=bold')
	vim.fn.execute('hi CocInfoVirtualText guibg=#' .. vim.g.base16_gui01 .. ' guifg=#' .. vim.g.base16_gui0B .. ' gui=NONE')
	vim.fn.execute('hi CocInfoHighlight gui=undercurl guisp=#' .. vim.g.base16_gui0B)

	vim.fn.execute('hi CocHintSign guibg=#' .. vim.g.base16_gui01 .. ' guifg=#' .. vim.g.base16_gui0C .. ' gui=bold')
	vim.fn.execute('hi CocHintVirtualText guibg=#' .. vim.g.base16_gui01 .. ' guifg=#' .. vim.g.base16_gui0C .. ' gui=NONE')
	vim.fn.execute('hi CocHintHighlight gui=undercurl guisp=#' .. vim.g.base16_gui0C)

	vim.fn.execute('hi CocExplorerGitContentChange guifg=#' .. vim.g.base16_gui0B)
end

util.augroup('vimrc', {
	'ColorScheme * lua require("plugins.coc").customize_colors()',
})

util.keys.lmap('n', ':CocCommand explorer<cr>')

vim.g.coc_explorer_global_presets = {
  floating = {
    position = 'floating',
    ['open-action-strategy'] = 'sourceWindow',
    ['floating-position'] = 'left-center',
    ['floating-width'] = 50,
  }
}

return coc
