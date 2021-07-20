local lspinstall = require('lspinstall')

-- setup all the currently installed servers
local function setup_servers()
  local lsp = require('lsp')
  lspinstall.setup()

  -- initialize the servers managed by lspinstall
  for _, server in pairs(lspinstall.installed_servers()) do
    lsp.setup_server(server)
  end
end

-- automatically reload servers after `:LspInstall <server>`
function lspinstall.post_install_hook()
  setup_servers()
  vim.cmd('bufdo e')
end

local exports = {}

-- list the currently installed servers
function exports.list_servers()
  print(table.concat(lspinstall.installed_servers(), ', '))
end

-- update the currently installed servers
function exports.update_servers()
  for _, server in pairs(lspinstall.installed_servers()) do
    lspinstall.install_server(server)
  end
end

setup_servers()

-- add some useful support commands
local cmd = require('util').cmd
cmd('LspList', 'lua require("plugins.nvim-lspinstall").list_servers()')
cmd('LspUpdate', 'lua require("plugins.nvim-lspinstall").update_servers()')

return exports
