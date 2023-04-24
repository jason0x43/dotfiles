local modbase = ...

-- Give LspInfo window a border
require('lspconfig.ui.windows').default_options.border = 'rounded'

---@param bufnr integer
---@param method string
local function lsp_method_supported(bufnr, method)
  ---@type lsp.Client[]
  local active_clients = vim.lsp.get_active_clients({ bufnr = bufnr })

  for _, active_client in pairs(active_clients) do
    if active_client.supports_method(method) then
      return true
    end
  end
end

---Adapted from M.code_actions() in $VIMRUNTIME/lua/vim/buf.lua
---@param bufnr integer
local function organize_imports(bufnr)
  if not lsp_method_supported(bufnr, 'textDocument/codeAction') then
    return
  end

  local params = vim.lsp.util.make_range_params()
  params.context = {
    diagnostics = {},
    only = { 'source.organizeImports', 'source.removeUnusedImports' },
  }

  local results =
    vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params)
  if results == nil then
    return
  end

  for client_id, result in pairs(results) do
    local client = vim.lsp.get_client_by_id(client_id)

    for _, action in pairs(result.result or {}) do
      if
        action.kind:find('source.organizeImports')
        or action.kind:find('source.removeUnusedImports')
      then
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        end

        if action.command then
          local command = type(action.command) == 'table' and action.command
            or action
          local fn = client.commands[command.command]
            or vim.lsp.commands[command.command]

          if fn then
            fn(command, {
              client_id = client.id,
              bufnr = bufnr,
              method = 'textDocument/codeAction',
              params = vim.deepcopy(params),
            })
          else
            -- Not using command directly to exclude extra properties,
            -- see https://github.com/python-lsp/python-lsp-server/issues/146
            client.request_sync('workspace/executeCommand', {
              command = command.command,
              arguments = command.arguments,
              workDoneToken = command.workDoneToken,
            }, nil, bufnr)
          end
        end
      end
    end
  end
end

local M = {}

---@alias AttachFunction fun(client: lsp.Client, bufnr: integer): nil

-- configure a client when it's attached to a buffer
---@param server_on_attach AttachFunction?
M.create_on_attach = function(server_on_attach)
  ---@param client lsp.Client
  ---@param bufnr integer
  return function(client, bufnr)
    if require('user.util').is_large_file(bufnr) then
      return
    end

    if server_on_attach then
      server_on_attach(client, bufnr)
    end

    local opts = { buffer = bufnr }

    -- navic can only attach to one client per buffer, so don't attach to
    -- clients that don't supply useful info
    if client.server_capabilities.documentSymbolProvider then
      require('nvim-navic').attach(client, bufnr)
    end

    -- add a jump to definition keymap; this overrides the default C-] keymap
    -- when an LSP is attached to a buffer
    if client.server_capabilities.definitionProvider then
      vim.keymap.set('n', '<C-]>', function()
        vim.lsp.buf.definition()
      end, opts)
    end

    -- add a hover info keymap; this overrides the default K keymap when an LSP
    -- is attached to a buffer
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('', 'K', function()
        vim.lsp.buf.hover()
      end, opts)
    end

    -- add a rename keymap
    if client.server_capabilities.renameProvider then
      vim.keymap.set('n', '<leader>r', function()
        vim.lsp.buf.rename()
      end, opts)
    end

    -- add a :Format command and keymap
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_buf_create_user_command(0, 'Format', function()
        vim.lsp.buf.format()
      end, {})

      vim.keymap.set('n', '<leader>F', function()
        vim.lsp.buf.format()
      end, opts)

      vim.api.nvim_buf_create_user_command(0, 'OrganizeImports', function()
        organize_imports(0)
      end, {})
    end

    -- keymap to show error diagnostic popup
    vim.keymap.set('n', '<leader>d', function()
      vim.diagnostic.open_float({
        border = 'rounded',
        focusable = false,
      })
    end, opts)
  end
end

M.config = function()
  -- configure diagnostic signs
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

  -- rounded border for hover popups
  vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })

  -- rounded border for signature popups
  vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

  -- when an lsp returns multiple "goto definition" results, only keep the
  -- first one
  local origTextDocDef = vim.lsp.handlers['textDocument/definition']
  vim.lsp.handlers['textDocument/definition'] = function(
    err,
    result,
    ctx,
    config
  )
    if result ~= nil and #result > 1 then
      result = { result[1] }
    end
    origTextDocDef(err, result, ctx, config)
  end
end

-- setup a server
---@param server_name string
M.setup = function(server_name)
  local status, config = pcall(require, modbase .. '.servers.' .. server_name)
  if not status or type(config) ~= 'table' then
    config = {}
  end

  config.on_attach = M.create_on_attach(config.on_attach)

  -- add cmp capabilities
  local cmp_caps = {}
  local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp');
  if ok then
    cmp_caps = cmp_nvim_lsp.default_capabilities()
  end

  if config.capabilities then
    config.capabilities =
      vim.tbl_deep_extend('keep', config.capabilities, cmp_caps)
  else
    config.capabilities = cmp_caps
  end

  require('lspconfig')[server_name].setup(config)
end

return M
