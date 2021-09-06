local modbase = ...

-- load the config for a given client, if it exists
local function load_client_config(server_name)
  local status, client_config = pcall(require, modbase .. '.' .. server_name)
  if not status or type(client_config) ~= 'table' then
    return {}
  end
  return client_config
end

-- configure a client when it's attached to a buffer
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr }

  -- run any client-specific attach functions
  local client_config = load_client_config(client.name)
  if client_config.on_attach then
    client_config.on_attach(client)
  end

  pcall(function()
    require('illuminate').on_attach(client)
  end)

  pcall(function()
    require('lsp_signature').on_attach({
      max_width = 80,
    })
  end)

  -- perform general setup

  local util = require('util')

  if client.resolved_capabilities.goto_definition then
    util.nmap('<C-]>', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  end

  if client.resolved_capabilities.hover then
    util.map('K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  end

  if client.resolved_capabilities.rename then
    util.lmap('r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  end

  if client.resolved_capabilities.document_formatting then
    util.cmd('Format', '-buffer', 'lua require("lsp").format_sync(nil, 5000)')
  end

  if not packer_plugins['trouble.nvim'] then
    util.lmap('e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', opts)
  end

  util.lmap('d', '<cmd>lua require("lsp").show_line_diagnostics()<cr>', opts)

  vim.cmd(
    'autocmd CursorHold <buffer> lua require("lsp").show_line_diagnostics()'
  )
end

local exports = {}

-- format the current buffer, handling the case where multiple formatters are
-- present
function exports.format_sync(options, timeout)
  local clients = vim.tbl_values(vim.lsp.buf_get_clients())
  local formatters = vim.tbl_filter(function(client)
    return client.supports_method('textDocument/formatting')
  end, clients)

  local formatter
  if #formatters == 0 then
    return
  end

  if #formatters == 1 then
    formatter = formatters[1]
  else
    local non_null_ls = vim.tbl_filter(function(client)
      return client.name ~= 'null-ls'
    end, formatters)
    formatter = non_null_ls[1]
  end

  local params = vim.lsp.util.make_formatting_params(options)
  local result, err = formatter.request_sync(
    'textDocument/formatting',
    params,
    timeout,
    vim.api.nvim_get_current_buf()
  )
  if result and result.result then
    vim.lsp.util.apply_text_edits(result.result)
  elseif err then
    vim.notify('vim.lsp.buf.formatting_sync: ' .. err, vim.log.levels.WARN)
  end
end

-- style the line diagnostics popup
function exports.show_line_diagnostics()
  vim.lsp.diagnostic.show_line_diagnostics({
    border = 'rounded',
    max_width = 80,
    show_header = false,
    focusable = false,
  })
end

-- setup a server
function exports.setup_server(server)
  -- default config for all servers
  local config = { on_attach = on_attach }

  -- add cmp capabilities
  local cmp = require('cmp_nvim_lsp')
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = cmp.update_capabilities(capabilities)
  config.capabilities = capabilities

  -- add server-specific config if applicable
  local client_config = load_client_config(server)
  if client_config.config then
    config = vim.tbl_extend('force', config, client_config.config)
  end

  require('lspconfig')[server].setup(config)
end

-- these are servers not managed by lspinstall
local manual_servers = { 'sourcekit' }
for _, server in ipairs(manual_servers) do
  exports.setup_server(server)
end

-- UI
vim.fn.sign_define('LspDiagnosticsSignError', { text = '' })
vim.fn.sign_define('LspDiagnosticsSignWarning', { text = '' })
vim.fn.sign_define('LspDiagnosticsSignInformation', { text = '' })
vim.fn.sign_define('LspDiagnosticsSignHint', { text = '' })

local lsp = vim.lsp

lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(
  lsp.handlers['textDocument/publishDiagnostics'],
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

return exports
