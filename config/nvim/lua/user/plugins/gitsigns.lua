local M = {}

M.config = function()
  require('user.req')('gitsigns', 'setup', {
    signs = {
      add = { text = '▋' },
      change = { text = '▋' },
    },
  })
end

return M
