local M = {}

M.config = function()
  require('user.req')('nvim-gps', 'setup')
end

return M
