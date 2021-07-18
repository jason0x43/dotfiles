local lspinstall = require('lspinstall')

-- setup all the currently installed servers
local function setup_servers()
  local lspconfig = require('lspconfig')
  local lsp = require('lsp')

  lspinstall.setup()

  -- initialize the servers managed by lspinstall
  for _, server in pairs(lspinstall.installed_servers()) do
    -- default config for all servers
    local config = { on_attach = lsp.on_attach }

    -- add server-specific config if applicable
    local client_config = lsp.load_client_config(server)
    if client_config.config then
      config = require('util').assign(config, client_config.config)
    end

    lspconfig[server].setup(config)
  end
end

local exports = {}

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

function exports.setup()
  setup_servers()

  -- add some useful support commands
  local cmd = require('util').cmd
  cmd('LspList', ':lua require("plugins.nvim-lspinstall").list_servers()<cr>')
  cmd('LspUpdate', ':lua require("plugins.nvim-lspinstall").update_servers()<cr>')
end

return exports
