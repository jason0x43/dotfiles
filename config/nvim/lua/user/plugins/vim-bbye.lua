local M = {}

M.config = function()
  local util = require('user.util')
  util.lmap('k', '<cmd>Bdelete<cr>')
  util.lmap('K', '<cmd>Bdelete!<cr>')
end

return M
