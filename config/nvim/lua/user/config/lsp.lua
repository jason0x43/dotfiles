-- Logging
vim.lsp.set_log_level('error')
vim.lsp.log.set_format_func(vim.inspect)

if not vim.fn.has('nvim-0.11') then
  -- Rounded border for hover popups
  vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })

  -- Rounded border for signature popups
  vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
end

-- When an lsp returns multiple "goto definition" results, only keep the
-- first one
local origTextDocDef = vim.lsp.handlers['textDocument/definition']
vim.lsp.handlers['textDocument/definition'] = function(err, result, ctx, config)
  if result ~= nil and #result > 1 then
    result = { result[1] }
  end
  origTextDocDef(err, result, ctx, config)
end

---Check whether a server should be started based on a user config
---@param config UserLspConfig
---@param file string
local function should_start(config, file)
  if config.should_start == false then
    return false
  end

  if type(config.should_start) == 'function' then
    return config.should_start(file)
  end

  return true
end

---The basic config object returned by lspconfig[server]
---@class(exact) BaseServer
---@field setup fun(config: PartialLspConfig): nil
---@field commands table<string, function>
---@field name string
---@field config_def lspconfig.Config

---The config object after calling config.setup()
---@class ConfiguredServer: BaseServer
---@field autostart boolean?
---@field cmd string[]?
---@field filetypes string[]?
---@field handlers table<string, function>?
---@field get_root_dir string|(fun(filename: string, bufnr: number): string)
---@field launch fun(): nil
---@field make_config fun(path: string): lspconfig.Config
---@field manager lspconfig.Manager

---Check if the server executable is available
---@param config ConfiguredServer
local function is_available(config)
  return config.cmd ~= nil and vim.fn.executable(config.cmd[1]) == 1
end

---Setup a language server
---@param server_name string
local function setup(server_name)
  ---@type PartialLspConfig
  local config = {
    autostart = false,
  }

  ---@type boolean, UserLspConfig
  local status, user_config = pcall(require, 'user.lsp.' .. server_name)
  if status and user_config and user_config.config then
    config = vim.tbl_deep_extend('force', config, user_config.config)
  end

  -- Add blink capabilities
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    config.capabilities = blink.get_lsp_capabilities(config.capabilities)
  end

  -- Make sure the server name is valid
  local base_server = require('lspconfig')[server_name] --[[@as BaseServer]]
  if base_server == nil then
    vim.notify('Unknown language server ' .. server_name, vim.log.levels.WARN)
    return false
  end

  -- Initialize the server
  base_server.setup(config)
  local server = base_server --[[@as ConfiguredServer]]

  -- Check if the server executable is available
  if not is_available(server) then
    return false
  end

  -- Setup an autocommand to start the server when a matching filetype is opened
  vim.api.nvim_create_autocmd('FileType', {
    pattern = server.filetypes,
    callback = function(event)
      if not should_start(user_config, event.file) then
        return
      end
      server.launch()
    end,
    desc = 'Start a language server',
  })

  return true
end

local ml = require('mason-lspconfig')

-- List of servers to setup
local servers = ml.get_installed_servers()
if vim.fn.executable('sourcekit-lsp') == 1 then
  table.insert(servers, 'sourcekit')
end

-- Setup servers
for _, server in ipairs(servers) do
  if not setup(server) then
    vim.notify('Failed to setup ' .. server, vim.log.levels.WARN)
  end
end
