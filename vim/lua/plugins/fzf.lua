local util = require('util')

_G.fzf = {}
local fzf = _G.fzf

-- Override the default files and buffers mappings with fzf ones
util.keys.lmap('f', ':Files<cr>')
util.keys.lmap('b', ':Buffers<cr>')

-- Show untracked files, too
util.keys.lmap('g', ':GFiles --cached --others --exclude-standard<cr>')
util.keys.lmap('m', ':GFiles?<cr>')

local fzf_opts = {
  '--info hidden',
  '--border rounded',

  -- grow the list down instead of up
  '--layout reverse',

  -- hide the pointer character
  '--pointer " "',

  -- hide the info line
  '--color "bg+:0"'
}

function fzf.floating_fzf()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.fn.setbufvar(buf, '&signcolumn', 'no')

  local cols = vim.go.columns
  local height = vim.fn.float2nr(vim.go.lines * 0.5)
  local width = vim.fn.float2nr(cols * 0.7)
  local horizontal = vim.fn.float2nr((cols - width) / 2)
  local vertical = 0

  -- style=minimal disables normal window features like line numbers
  local opts = {
    relative = 'editor',
    row = vertical,
    col = horizontal,
    width = width,
    height = height,
    style = 'minimal'
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:FzfFloat')
end

util.hi('FzfFloat', { guibg = '', ctermbg = '' })

vim.g.fzf_preview_window = {}
vim.g.fzf_layout = { window = 'lua fzf.floating_fzf()' }

if vim.fn.exists('$FZF_DEFAULT_OPTS') == 1 then
  table.insert(fzf_opts, 1, vim.fn.getenv('FZF_DEFAULT_OPTS'))
end

vim.fn.setenv('FZF_DEFAULT_OPTS', table.concat(fzf_opts, ' '))
