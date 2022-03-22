local M = {}

M.config = function()
  require('user.req')('diffview', 'setup')
end

return M
