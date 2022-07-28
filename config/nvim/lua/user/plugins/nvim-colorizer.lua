local M = {}

M.config = function()
  require('user.req')('colorizer', 'setup', { '*' }, {
    names = false,
    rgb_fn = true
  })
end

return M
