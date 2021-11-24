local M = {}

M.config = {
  on_attach = function()
    require('util').bufcmd('OrganizeImports', 'PyrightOrganizeImports')
  end
}

return M
