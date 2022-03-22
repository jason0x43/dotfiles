local M = {}

M.config = function()
  require('user.req')('trouble', 'setup')
end

return M
