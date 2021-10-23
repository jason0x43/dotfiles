local M = {}

function M.on_attach()
  require('util').cmd('OrganizeImports', '-buffer', 'PyrightOrganizeImports')
end

return M
