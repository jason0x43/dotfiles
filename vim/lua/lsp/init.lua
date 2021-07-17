local util = require('util')
local modbase = ...

local exports = {}

function exports.show_line_diagnostics()
  vim.lsp.diagnostic.show_line_diagnostics({
    border = 'rounded',
    max_width = 80,
  })
end

function exports.load_client_config(server_name)
  local _, client_config = pcall(require, modbase .. '.' .. server_name)
  return client_config or {}
end

-- configure a client when it's attached to a buffer
function exports.on_attach(client, bufnr)
  local opts = { buffer = bufnr }

  -- run any client-specific attach functions
  local client_config = exports.load_client_config(client.name)
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

  if not packer_plugins['trouble.nvim'] then
    util.keys.lmap('e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', opts)
  end
  util.keys.lmap(
    'd',
    '<cmd>lua require("lsp").show_line_diagnostics()<cr>',
    opts
  )
end

function exports.setup()
  local lsp = vim.lsp

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
end

return exports
