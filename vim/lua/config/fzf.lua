local util = require('util')

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

if vim.fn.exists('$FZF_DEFAULT_OPTS') == 1 then
  table.insert(fzf_opts, 1, vim.fn.getenv('FZF_DEFAULT_OPTS'))
end

vim.fn.setenv(
	'FZF_DEFAULT_OPTS',
	table.concat(fzf_opts, ' ')
)
