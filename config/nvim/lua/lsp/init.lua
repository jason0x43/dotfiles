local modbase = ...
local util = require('util')

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

  if client.resolved_capabilities.completion then
    -- enable lsp completions
    vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- apply any additional fixups after a completion is accepted
    vim.cmd('augroup lsp-completion')
    vim.cmd(
      'autocmd! CompleteDone <buffer> lua require("lsp").on_complete_done()'
    )
    vim.cmd('augroup END')
  end

  if not packer_plugins['trouble.nvim'] then
    util.lmap('e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', opts)
  end

  util.lmap(
    'd',
    '<cmd>lua require("lsp").show_position_diagnostics()<cr>',
    opts
  )
end

local M = {}

-- apply additionalTextEdits, such as auto imports, when a completion is
-- accepted
function M.on_complete_done()
  local bufnr = vim.api.nvim_get_current_buf()
  local completed_item = vim.v.completed_item

  if
    completed_item
    and completed_item.user_data
    and completed_item.user_data.nvim
    and completed_item.user_data.nvim.lsp
    and completed_item.user_data.nvim.lsp.completion_item
  then
    vim.lsp.buf_request(
      bufnr,
      'completionItem/resolve',
      completed_item.user_data.nvim.lsp.completion_item,
      function(err, result, ctx)
        if err or not result then
          return
        end
        if result.additionalTextEdits then
          vim.lsp.util.apply_text_edits(result.additionalTextEdits, bufnr)
        end
      end
    )
  end
end

-- format the current buffer, handling the case where multiple formatters are
-- present
function M.format_sync(options, timeout)
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
function M.show_position_diagnostics()
  vim.diagnostic.open_float(0, {
    scope = 'cursor',
    float = {
      border = 'rounded',
      max_width = 80,
      show_header = false,
      focusable = false,
    },
  })
end

-- setup a server
function M.get_lsp_config(server)
  -- default config for all servers
  local config = { on_attach = on_attach }

  -- add cmp capabilities
  local cmp = util.srequire('cmp_nvim_lsp')
  if cmp then
    config.capabilities = cmp.update_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    )
  end

  -- add server-specific config if applicable
  local client_config = load_client_config(server)
  if client_config.config then
    config = vim.tbl_deep_extend('force', config, client_config.config)
  end

  return config
end

-- these are servers not managed by lspinstall
local manual_servers = { 'sourcekit' }
for _, server in ipairs(manual_servers) do
  local config = M.get_lsp_config(server)
  require('lspconfig')[server].setup(config)
end

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

local orig_buf_attach_client = lsp.buf_attach_client

function lsp.buf_attach_client(bufnr, client_id)
  local client = lsp.get_client_by_id(client_id)
  if client.name == 'denols' then
    local clients = lsp.buf_get_clients(bufnr)
    for _, c in ipairs(clients) do
      if c.name == 'tsserver' then
        -- Don't attach deno to a buffer that already has tsserver attached
        return
      end
    end
  end
  return orig_buf_attach_client(bufnr, client_id)
end

return M
