local util = require('util')
local hi = util.hi
local g = vim.g

-- Create a global namespace for the coc utilities
_G.coc = {}
local coc = _G.coc

-- Set the registry for VIM to make COC happy
vim.fn.setenv('npm_config_registry', 'https://registry.npmjs.org')

g.coc_node_path = vim.fn.expand('$HOMEBREW_BASE/bin/node')

vim.fn['coc#config']('session.directory', util.data_home .. '/nvim/sessions')

if g['fzf#vim#buffers'] == nil then
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

util.keys.map('K', ':call v:lua.coc.show_documentation()<cr>')

util.augroup('init_coc', {
  'User CocJumpPlaceholder call CocActionAsync("showSignatureHelp")',
  'CursorHold * silent call CocActionAsync("highlight")',
  'ColorScheme * call v:lua.coc.customize_colors()',
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

util.keys.lmap('e', ':CocFzfList diagnostics<cr>')
util.keys.lmap('l', ':CocFzfList<cr>')
util.keys.lmap('x', '<Plug>(coc-codeaction)')

util.keys.map('<M-f>', '<Plug>(coc-format)')
util.keys.nmap('<C-]>', '<Plug>(coc-definition)')
util.keys.lmap('t', '<Plug>(coc-format-selected)')
util.keys.lmap('r', '<Plug>(coc-rename)')
util.keys.lmap('j', '<Plug>(coc-references)')
util.keys.lmap('d', '<Plug>(coc-diagnostic-info)')

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

g.coc_global_extensions = {
  'coc-calc',
  'coc-css',
  'coc-emmet',
  'coc-emoji',
  'coc-eslint',
  -- 'coc-explorer',
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

g.coc_status_error_sign = ' '
g.coc_status_info_sign = ' '
g.coc_status_hint_sign = ' '
g.coc_status_warning_sign = ' '

g.coc_snippet_next = '<tab>'
g.coc_snippet_prev = '<S-tab>'
g.coc_disable_startup_warning = 1

function coc.customize_colors()
  hi('CocErrorSign', {
    guibg = g.base16_gui01k,
    guifg = g.base16_gui0F,
    gui = 'bold'
  })
  hi('CocErrorVirtualText', {
    guibg = g.base16_gui01,
    guifg = g.base16_gui0F,
    gui = ''
  })
  hi('CocErrorHighlight', { gui = 'undercurl', guisp = g.base16_gui0F })

  hi('CocWarningSign', {
    guibg = g.base16_gui01,
    guifg = g.base16_gui08,
    gui = 'bold'
  })
  hi('CocWarningVirtualText', {
    guibg = g.base16_gui01,
    guifg = g.base16_gui08,
    gui = ''
  })
  hi('CocWarningHighlight', { gui = 'undercurl', guisp = g.base16_gui08 })

  hi('CocInfoSign', {
    guibg = g.base16_gui01,
    guifg = g.base16_gui0B,
    gui = 'bold'
  })
  hi('CocInfoVirtualText', {
    guibg = g.base16_gui01,
    guifg = g.base16_gui0B,
    gui = ''
  })
  hi('CocInfoHighlight', { gui = 'undercurl', guisp = g.base16_gui0B })

  hi('CocHintSign', {
    guibg = g.base16_gui01,
    guifg = g.base16_gui0C,
    gui = 'bold'
  })
  hi('CocHintVirtualText', {
    guibg = g.base16_gui01,
    guifg = g.base16_gui0C,
    gui = ''
  })
  hi('CocHintHighlight', {
    gui = 'undercurl',
    guisp = g.base16_gui0C
  })

  -- hi('CocExplorerGitContentChange', { guifg = g.base16_gui0B })
end

-- util.keys.lmap('n', ':CocCommand explorer<cr>')

-- g.coc_explorer_global_presets = {
--   floating = {
--     position = 'floating',
--     ['open-action-strategy'] = 'sourceWindow',
--     ['floating-position'] = 'left-center',
--     ['floating-width'] = 50,
--   }
-- }

return coc
