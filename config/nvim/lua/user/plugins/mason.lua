local M = {}

M.config = function()
  require('user.req')('mason', 'setup')
  require('user.req')('mason-lspconfig', 'setup')
  print('setup mason lspconfig')
end

return M
