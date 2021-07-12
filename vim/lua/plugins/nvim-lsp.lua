local util = require('util')
local lspconfig = require('lspconfig')
local lspinstall = require('lspinstall')
local lsp = vim.lsp

_G.lsp_util = {}
local lsp_util = _G.lsp_util

lspinstall.setup()

-- UI
vim.fn.sign_define('LspDiagnosticsSignError', { text = '' })
vim.fn.sign_define('LspDiagnosticsSignWarning', { text = '' })
vim.fn.sign_define('LspDiagnosticsSignInformation', { text = '' })
vim.fn.sign_define('LspDiagnosticsSignHint', { text = '' })

lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)

lsp.handlers['textDocument/hover'] = lsp.with(
  lsp.handlers.hover, { border = 'rounded' }
)

lsp.handlers['textDocument/signatureHelp'] = lsp.with(
  lsp.handlers.signature_help, { border = 'rounded' }
)

function lsp_util.show_line_diagnostics()
  vim.lsp.diagnostic.show_line_diagnostics({ border = 'rounded' })
end

-- configure a client when it's attached to a buffer
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr }

  -- run any client-specific attach functions
  if client.name == 'typescript' then
    require('plugins.nvim-lsp.typescript').on_attach(client)
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

local servers_with_config = { 'efm', 'lua', 'json' }
local disabled_servers = { 'deno' }

-- setup all the currently installed servers
local function setup_servers()
  local servers = vim.tbl_filter(
    function(name)
      return not vim.tbl_contains(disabled_servers, name)
    end, lspinstall.installed_servers()
  )

  for _, server in pairs(servers) do
    -- default config for all servers
    local config = { on_attach = on_attach }

    -- add server-specific config if applicable
    if vim.tbl_contains(servers_with_config, server) then
      config =
        util.extend(config, require('plugins.nvim-lsp.' .. server).config)
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
function lsp_util.list_servers()
  print(vim.inspect(lspinstall.installed_servers()))
end

-- update the currently installed servers
function lsp_util.update_servers()
  for _, server in pairs(lspinstall.installed_servers()) do
    lspinstall.install_server(server)
  end
end

-- add some useful support commands
util.cmd('LspList', ':lua lsp_util.list_servers()<cr>')
util.cmd('LspUpdate', ':lua lsp_util.update_servers()<cr>')
