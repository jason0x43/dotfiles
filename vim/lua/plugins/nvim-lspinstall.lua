-- setup all the currently installed servers
local function setup_servers()
  local lspinstall = require('lspinstall')
  local lspconfig = require('lspconfig')
  local lsp = require('lsp')

  -- initialize the servers managed by lspinstall
  lspinstall.setup()
  for _, server in pairs(lspinstall.installed_servers()) do
    -- default config for all servers
    local config = { on_attach = lsp.on_attach }

    -- add server-specific config if applicable
    local client_config = lsp.load_client_config(server)
    if client_config.config then
      config = util.assign(config, client_config.config)
    end

    lspconfig[server].setup(config)
  end

  -- null-ls isn't handled by lspconfig
end

setup_servers()

local exports = {}
local lspinstall = require('lspinstall')

-- automatically reload servers after `:LspInstall <server>`
function lspinstall.post_install_hook()
  setup_servers()
  vim.cmd('bufdo e')
end

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

-- add some useful support commands
util.cmd('LspList', ':lua lsp_util.list_servers()<cr>')
util.cmd('LspUpdate', ':lua lsp_util.update_servers()<cr>')

_G.lsp_util = exports
return exports
