local util = require('user.util')

vim.api.nvim_create_augroup('init_autocmds', {})

local function autocmd(type, pattern, callback)
  vim.api.nvim_create_autocmd(type, {
    group = 'init_autocmds',
    pattern = pattern,
    callback = callback,
  })
end

-- make text files easier to work with
autocmd('FileType', 'text,textile,markdown,html', function()
  util.text_mode()
end)

-- better formatting for JavaScript
autocmd('FileType', 'javascript', function()
	vim.bo.formatprg = nil
	vim.bo.formatexpr = nil
end)

autocmd('BufEnter', '*.*', function()
  -- show the current textwidth with color columns
  require('user.util').show_view_width()
end)

autocmd('VimResized', '*', function()
  -- automatically resize splits
  vim.api.nvim_command('wincmd =')

  -- show line numbers if the window is big enough
  vim.opt.number = vim.go.columns > 88
end)

-- wrap lines in quickfix windows
autocmd('FileType', 'qf', function()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.list = false
  vim.wo.breakindent = false
  vim.wo.breakindentopt = 'shift:2'
  vim.wo.colorcolumn = ''
end)

-- don't use the colorcolumn in Trouble windows
autocmd('FileType', 'Trouble', function()
  vim.wo.colorcolumn = ''
end)

-- don't show sign column in help panes
autocmd('FileType', 'help', function()
  vim.wo.signcolumn = 'no'
end)

-- close qf panes and help tabs with 'q'
autocmd('FileType', 'qf,fugitiveblame,lspinfo,startuptime', function()
  vim.keymap.set('', 'q', '<cmd>bd<CR>')
end)
autocmd('FileType', 'help', function()
  vim.keymap.set('', 'q', '<cmd>tabclose<CR>')
end)
autocmd('BufEnter', 'output:///info', function()
  vim.keymap.set('', 'q', '<cmd>bd<CR>')
end)

-- auto-set quickfix height
autocmd('FileType', 'qf', function()
  require('user.util').adjust_window_height(1, 10)
end)

-- highlight yanked text
autocmd('TextYankPost', '*', function()
  vim.highlight.on_yank({
    higroup = 'IncSearch',
    timeout = 150,
    on_visual = true,
  })
end)

-- restore cursor position when opening a file
-- run this in BufWinEnter instead of BufReadPost so that this won't override
-- a line number provided on the commandline
autocmd('BufWinEnter', '*', function()
  require('user.util').restore_cursor()
end)

-- set filetypes
local function autoft(pattern, filetype)
  autocmd({ 'BufNewFile', 'BufRead' }, pattern, function()
    vim.bo.filetype = filetype
  end)
end

autoft('.envrc', 'bash')
autoft('fish_funced.*', 'fish')
autoft('*.ejs', 'html')
autoft('.{jscsrc,bowerrc,tslintrc,eslintrc,dojorc,prettierrc}', 'json')
autoft('.dojorc-*', 'json')
autoft('*.dashtoc', 'json')
autoft('Podfile', 'ruby')
autoft('*/zsh/functions/*', 'zsh')
autoft('{ts,js}config.json', 'jsonc')
autoft('intern.json', 'jsonc')
autoft('intern{-.}*.json', 'jsonc')
autoft('*.textile', 'textile')
autoft('*.{frag,vert}', 'glsl')

-- set colorscheme after TUI has loaded
autocmd('VimEnter', '*', function()
  local timer = vim.loop.new_timer()
  timer:start(
    0,
    0,
    vim.schedule_wrap(function()
      vim.api.nvim_command('colorscheme wezterm')
    end)
  )
end)

-- improve handling of very large files
autocmd({ 'BufReadPre', 'FileReadPre' }, '*', function()
  local file = vim.fn.expand('<afile>')
  local size = vim.fn.getfsize(file)

  -- "large" is > 10MB
  if size > 10000000 then
    print('Using large file mode for ' .. file)

    if vim.fn.exists(':TSBufDisable') then
      vim.cmd('TSBufDisable highlight indent illuminate matchup')
    end

    -- if vim.fn.exists(':IlluminatePauseBuf') then
    --   vim.cmd('IlluminatePauseBuf')
    -- end

    vim.b.lsp_disable = true
    vim.wo.foldmethod = 'manual'
    vim.cmd('syntax off')
    vim.cmd('filetype off')
    vim.bo.swapfile = false
    vim.bo.undofile = false
  end
end)

-- show line numbers if the window is big enough
autocmd('VimResized', '*', function()
  vim.wo.number = vim.go.columns > 88
end)
