local util = require('util')

local project_root = vim.fn.system(
  'git rev-parse --show-toplevel 2> /dev/null'
)

if project_root then
	project_root = vim.trim(project_root)
	local bindir = project_root .. '/node_modules/.bin'
	if vim.fn.isdirectory(bindir) == 1 then
		vim.fn.setenv('PATH', bindir .. ':' .. vim.fn.getenv('PATH'))
	end
end
