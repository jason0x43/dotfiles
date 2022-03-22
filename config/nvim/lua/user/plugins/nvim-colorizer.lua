local M = {}

M.config = function()
  require('user.req')('colorizer', 'setup', { '*' }, { names = false })
end

return M
