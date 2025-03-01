-- Leader for mappings
vim.g.mapleader = ';'

-- Default tabstop and shiftwidth
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Don't wrap lines by default
vim.o.wrap = false

-- Ask for confirmation if exiting with modified files
vim.o.confirm = true

-- Yank to system clipboard
if vim.fn.has('clipboard') == 1 then
  vim.opt.clipboard = vim.opt.clipboard + 'unnamedplus'
end

-- Disable ruler display
vim.o.ruler = false

-- Use undo files for persistent undo
vim.o.undofile = true

-- Maintain indent when lines are broken by linebreak
vim.o.breakindent = true

-- Ignore case when searching, unless the search is mixed case
vim.o.ignorecase = true
vim.o.smartcase = true

-- Give the cursor a 5 line margin when scrolling
vim.o.scrolloff = 5

-- always show the sign column
vim.o.signcolumn = 'yes'

-- Open splits below and to the right, and don't scroll
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.splitkeep = 'topline'

-- Don't add EOL to files that don't already have one
vim.o.fixendofline = false

-- Formatting while typing
vim.opt.formatoptions = vim.opt.formatoptions
  + 'r' -- automatically insert comment leader after CR
  + 'o' -- automatically insert comment leader for o/O
  + 'n' -- recognize numbered lists

-- Use case-insensitive filename completion
vim.o.wildignorecase = true

-- Enable mouse support
vim.o.mouse = 'a'

-- Show markers for long lines
vim.opt.listchars.precedes = '^'
vim.opt.listchars.extends = '$'

-- Ignore some binary files in the standard vim finder
vim.opt.wildignore = vim.opt.wildignore + '*.pyc' + '*.obj' + '*.bin' + 'a.out'

-- Use a better default diffing algorithm
vim.opt.diffopt = vim.opt.diffopt + { 'internal', 'algorithm:patience' }

-- Show line numbers if the window is wide enough
vim.o.number = vim.o.columns >= 88

-- Use ripgrep if available
if vim.fn.executable('rg') then
  vim.o.grepprg = 'rg --no-heading --color=never'
end

-- Better folding
vim.o.foldenable = false
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldcolumn = 'auto'
vim.opt.fillchars:append('foldopen:▼')
vim.opt.fillchars:append('foldclose:▶')
vim.api.nvim_create_user_command('Fold', function()
  vim.wo.foldenable = not vim.wo.foldenable
end, { desc = 'Toggle semantic code folding' })

-- General diagnostic config
vim.diagnostic.config({
  -- Faster update
  update_in_insert = true,

  -- Specify some diagnostic icons
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
  },
})

-- Highlight textwidth
vim.opt.colorcolumn = { '+1' }

-- Don't animate neovide cursor
if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
end

-- Disable unneeded builtin plugins
-- The value of the loaded var doesn't matter, just that it's defined
local disabled_plugins = {
  '2html_plugin',
  'gzip',
  'matchit',
  'matchparen',
  'netrw',
  'netrwFileHandlers',
  'netrwPlugin',
  'netrwSettings',
  'spellfile_plugin',
  'tutor_mode_plugin',
  'vimball',
  'vimballPlugin',
}
for _, plugin in ipairs(disabled_plugins) do
  vim.g['loaded_' .. plugin] = 1
end

if vim.fn.has('nvim-0.11') then
  local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
  ---@diagnostic disable-next-line: duplicate-set-field
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'rounded'
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
  end
end
