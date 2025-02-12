-- Logging
vim.lsp.set_log_level('error')
vim.lsp.log.set_format_func(vim.inspect)

-- Rounded border for hover popups
vim.lsp.handlers['textDocument/hover'] =
  vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })

-- Rounded border for signature popups
vim.lsp.handlers['textDocument/signatureHelp'] =
  vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

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
---@param user_config UserLspConfig
---@param file string
local function check_should_start(user_config, file)
  if user_config.should_start == false then
    return false
  end

  if type(user_config.should_start) == 'function' then
    return user_config.should_start(file)
  end

  return true
end

---Setup a language server
---@param server_name string
local function setup(server_name)
  ---@type LspConfig
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

  -- Initialize the server
  local server = require('lspconfig')[server_name]
  server.setup(config)

  if server.manager == nil then
    vim.notify(server_name .. ' is not a language server', vim.log.levels.ERROR)
    return
  end

  local exec = server.manager.config.cmd[1]
  if not vim.fn.executable(exec) then
    vim.notify(
      string.format(
        'Not setting up %s because %s is not installed',
        server_name,
        exec
      ),
      vim.log.levels.WARN
    )
    return
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = server.manager.config.filetypes,
    callback = function(event)
      if not check_should_start(user_config, event.file) then
        return
      end
      server.launch()
    end,
  })
end

-- List of servers to setup
local servers = {
  'angularls',
  'basedpyright',
  'bashls',
  'cssls',
  'denols',
  'docker_compose_language_service',
  'dockerls',
  'eslint',
  'gopls',
  'gradle_ls',
  'html',
  'intelephense',
  'jdtls',
  'jinja_lsp',
  'jsonls',
  'lua_ls',
  -- Note that marksman may not initialize properly if there are too many files
  -- in a project. Ensure that the .gitignore is correct.
  'marksman',
  'omnisharp',
  'phpactor',
  'ruff',
  'rust_analyzer',
  'solargraph',
  'sourcekit',
  'sqlls',
  'svelte',
  'tailwindcss',
  'taplo',
  'texlab',
  'vacuum',
  'vimls',
  'vtsls',
  'yamlls',
}

-- Setup servers
for _, server in ipairs(servers) do
  setup(server)
end
