local o = vim.opt

-- overwrite the original file when saving
o.backupcopy = 'yes'

-- use undo files for persistent undo
o.undofile = true

-- maintain indent when lines are broken by linebreak
o.breakindent = true

-- show commands in the command area, don't show 'Press Enter to continue'
o.showcmd = true

-- use hidden buffers
o.hidden = true

-- ignore case when searching, unless the search is mixed case
o.ignorecase = true
o.smartcase = true

-- only insert one space after a period when joining lines
o.joinspaces = false

-- don't move to the beginning of a line when jumping
o.startofline = false

-- show line numbers
o.number = true

-- give the cursor a 5 line margin when scrolling
o.scrolloff = 5

-- 4-space indents
o.shiftwidth = 4
o.tabstop = 4

-- don't give ins-completion-menu messages
o.shortmess = o.shortmess + 'c'

-- always show the sign column
o.signcolumn = 'yes'

-- open splits below and to the right
o.splitbelow = true
o.splitright = true

o.formatoptions = o.formatoptions
  + 'r' -- automatically insert comment leader after CR
  + 'o' -- automatically insert comment leader for o/O
  + 'n' -- recognize numbered lists

-- show location in statusline
o.ruler = true

-- don't wrap text by default
o.wrap = false

-- use case-insensitive filename completion
o.wildignorecase = true

-- update the UI more frequently, but skip some redraws
o.lazyredraw = true
o.updatetime = 500

-- don't show the mode on the last line
o.showmode = false

-- enable mouse support
o.mouse = 'a'

-- enable truecolor mode
o.termguicolors = true

-- inmprove completion
o.completeopt = o.completeopt + { 'menuone', 'noinsert', 'noselect' }

-- show markers for long lines
o.listchars.precedes = '^'
o.listchars.extends = '$'

-- ignore binary files in the standard vim finder
o.wildignore = o.wildignore + '*.pyc' + '*.obj' + '*.bin' + 'a.out'

-- better diffing
o.diffopt = o.diffopt + { 'internal', 'algorithm:patience' }

-- set python version for pyx commands
if vim.fn.has('pythonx') == 1 then
  o.pyxversion = 3
end

-- use ripgrep if available
if vim.fn.executable('rg') then
  o.grepprg = 'rg --no-heading --color=never'
end
