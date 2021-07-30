local exports = {}

function exports.on_attach()
  require('util').cmd('OrganizeImports', '-buffer', 'PyrightOrganizeImports')
end

return exports
