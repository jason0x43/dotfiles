local M = {}

M.config = {
  on_attach = {
    require('util').bufcmd('OrganizeImports', 'PyrightOrganizeImports')
  }
}

return M
