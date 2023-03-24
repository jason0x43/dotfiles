local modbase = ...

-- Give LspInfo window a border
require('lspconfig.ui.windows').default_options.border = 'rounded'

-- load the config for a given client, if it exists
local function load_client_config(server_name)
  local status, client_config =
    pcall(require, modbase .. '.servers.' .. server_name)
  if not status or type(client_config) ~= 'table' then
    return {}
  end
  return client_config
end

local M = {}

function M.config()
  -- UI
  vim.fn.sign_define(
    'DiagnosticSignError',
    { text = '', texthl = 'DiagnosticSignError' }
  )
  vim.fn.sign_define(
    'DiagnosticSignWarn',
    { text = '', texthl = 'DiagnosticSignWarn' }
  )
  vim.fn.sign_define(
    'DiagnosticSignInfo',
    { text = '', texthl = 'DiagnosticSignInfo' }
  )
  vim.fn.sign_define(
    'DiagnosticSignHint',
    { text = '', texthl = 'DiagnosticSignHint' }
  )

  vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.handlers['textDocument/publishDiagnostics'],
    { virtual_text = true }
  )

  vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })

  vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

  local origTextDocDef = vim.lsp.handlers['textDocument/definition']
  vim.lsp.handlers['textDocument/definition'] = function(
    err,
    result,
    ctx,
    config
  )
    -- If tsserver returns multiple results, only keep the first one
    if result ~= nil and #result > 1 then
      result = { result[1] }
    end
    origTextDocDef(err, result, ctx, config)
  end
end

-- configure a client when it's attached to a buffer
function M.on_attach(client, bufnr)
  local opts = { buffer = bufnr }

  -- navic can only attach to one client per buffer, so don't attach to clients
  -- that don't supply useful info
  if client.server_capabilities.documentSymbolProvider then
    require('nvim-navic').attach(client, bufnr)
  end

  if client.server_capabilities.definitionProvider then
    vim.keymap.set('n', '<C-]>', function()
      vim.lsp.buf.definition()
    end, opts)
  end

  if client.server_capabilities.hoverProvider then
    vim.keymap.set('', 'K', function()
      vim.lsp.buf.hover()
    end, opts)
  end

  if client.server_capabilities.renameProvider then
    vim.keymap.set('n', '<leader>r', function()
      vim.lsp.buf.rename()
    end, opts)
  end

  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_buf_create_user_command(0, 'Format', function()
      require('user.lsp').format()
    end, {})
    vim.keymap.set('n', '<leader>F', function()
      require('user.lsp').format()
    end, opts)
  end

  vim.keymap.set('n', '<leader>d', function()
    require('user.lsp').show_position_diagnostics()
  end, opts)
end

-- format the current buffer, but exclude certain cases
function M.format()
  local name = vim.api.nvim_buf_get_name(0)

  -- don't autoformat ignored code
  local response = vim.fn.system({ 'git', 'is-ignored', name })
  if response == '1' then
    return
  end

  -- don't autoformat library code
  if
    name:find('/node_modules/')
    or name:find('/__pypackages__/')
    or name:find('/site_packages/')
  then
    return
  end

  vim.lsp.buf.format()
end

-- style the line diagnostics popup
function M.show_position_diagnostics()
  vim.diagnostic.open_float(0, {
    scope = 'cursor',
    border = 'rounded',
    max_width = 80,
    show_header = false,
    focusable = false,
  })
end

-- setup a server
function M.get_lsp_config(server)
  -- default config for all servers
  local config = {}

  -- add server-specific config if applicable
  local client_config = load_client_config(server)
  if client_config.config then
    config = vim.tbl_deep_extend('force', config, client_config.config)
  end

  if config.on_attach then
    local config_on_attach = config.on_attach
    config.on_attach = function(client, bufnr)
      config_on_attach(client, bufnr)
      M.on_attach(client, bufnr)
    end
  else
    config.on_attach = M.on_attach
  end

  -- add cmp capabilities
  local cmp = require('cmp_nvim_lsp')
  config.capabilities = cmp.default_capabilities()

  return config
end

return M
