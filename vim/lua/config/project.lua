local util = require('util')

if util.project_root then
  local bindir = util.project_root .. '/node_modules/.bin'
  if vim.fn.isdirectory(bindir) == 1 then
    vim.fn.setenv('PATH', bindir .. ':' .. vim.fn.getenv('PATH'))
  end
end
