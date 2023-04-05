local modbase = ...

-- Give LspInfo window a border
require('lspconfig.ui.windows').default_options.border = 'rounded'

local M = {}

-- configure a client when it's attached to a buffer
M.create_on_attach = function(server_on_attach)
  return function(client, bufnr)
    if server_on_attach then
      server_on_attach(client, bufnr)
    end

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
end

M.config = function()
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

-- format the current buffer, but exclude certain cases
M.format = function()
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
M.show_position_diagnostics = function()
  vim.diagnostic.open_float({
    scope = 'cursor',
    border = 'rounded',
    max_width = 80,
    show_header = false,
    focusable = false,
  })
end

-- setup a server
M.setup = function(server_name)
  local status, config = pcall(require, modbase .. '.servers.' .. server_name)
  if not status or type(config) ~= 'table' then
    config = {}
  end

  config.on_attach = M.create_on_attach(config.on_attach)

  -- add cmp capabilities
  local cmp_caps = require('cmp_nvim_lsp').default_capabilities()
  if config.capabilities then
    config.capabilities =
      vim.tbl_deep_extend('keep', config.capabilities, cmp_caps)
  else
    config.capabilities = cmp_caps
  end

  require('lspconfig')[server_name].setup(config)
end

return M
