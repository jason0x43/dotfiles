local modbase = ...
local util = require('user.util')

local M = {}

---@alias AttachFunction fun(client: vim.lsp.Client, bufnr: integer): nil

-- configure a client when it's attached to a buffer
---@param server_on_attach AttachFunction?
M.create_on_attach = function(server_on_attach)
  ---@param client vim.lsp.Client
  ---@param bufnr integer
  return function(client, bufnr)
    if server_on_attach then
      server_on_attach(client, bufnr)
    end

    local opts = { buffer = bufnr }

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
      util.user_buf_cmd('Rename', function()
        vim.lsp.buf.rename()
      end)
    end

    -- add a :Format command and keymap
    if client.server_capabilities.documentFormattingProvider then
      util.user_buf_cmd('OrganizeImports', function()
        organize_imports(0)
      end)
    end

    -- show error diagnostic popup for the current line
    util.user_buf_cmd('Diag', function()
      vim.diagnostic.open_float({
        border = 'rounded',
      })
    end)
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
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    cmp_caps = blink.get_lsp_capabilities(config.capabilities)
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
