local util = require('util')
local lspconfig = require('lspconfig')
local lspinstall = require('lspinstall')
local lsp = vim.lsp
local modbase = ...

local exports = {}

-- UI
vim.fn.sign_define('LspDiagnosticsSignError', { text = '' })
vim.fn.sign_define('LspDiagnosticsSignWarning', { text = '' })
vim.fn.sign_define('LspDiagnosticsSignInformation', { text = '' })
vim.fn.sign_define('LspDiagnosticsSignHint', { text = '' })

lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics,
  { virtual_text = false }
)

lsp.handlers['textDocument/hover'] = lsp.with(
  lsp.handlers.hover,
  { border = 'rounded' }
)

lsp.handlers['textDocument/signatureHelp'] = lsp.with(
  lsp.handlers.signature_help,
  { border = 'rounded' }
)

function exports.show_line_diagnostics()
  vim.lsp.diagnostic.show_line_diagnostics({ border = 'rounded' })
end

local function load_client_config(server_name)
  local _, client_config = pcall(require, modbase .. '.' .. server_name)
  return client_config or {}
end

-- configure a client when it's attached to a buffer
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr }

  -- run any client-specific attach functions
  local client_config = load_client_config(client.name)
  if client_config.on_attach then
    client_config.on_attach(client)
  end

  -- perform general setup
  require('illuminate').on_attach(client)

  if client.resolved_capabilities.goto_definition then
    util.keys.nmap('<C-]>', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  end

  if client.resolved_capabilities.hover then
    util.keys.map('K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  end

  if client.resolved_capabilities.rename then
    util.keys.lmap('r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  end

  if client.resolved_capabilities.document_formatting then
    util.cmd('Format', '-buffer', 'lua vim.lsp.buf.formatting_sync(nil, 10000)')
  end

  util.keys.lmap('e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', opts)
  util.keys.lmap('d', '<cmd>lua lsp_util.show_line_diagnostics()<cr>', opts)
end

-- setup all the currently installed servers
local function setup_servers()
  lspinstall.setup()

  for _, server in pairs(lspinstall.installed_servers()) do
    -- default config for all servers
    local config = { on_attach = on_attach }

    -- add server-specific config if applicable
    local client_config = load_client_config(server)
    if client_config.config then
      config = util.assign(config, client_config.config)
    end

    lspconfig[server].setup(config)
  end
end

setup_servers()

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
