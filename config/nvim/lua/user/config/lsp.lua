-- Disable log by default
vim.lsp.set_log_level('error')

vim.diagnostic.config({
  -- faster update
  update_in_insert = true,

  -- specify some diagnostic icons
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
  },
})

-- rounded border for hover popups
vim.lsp.handlers['textDocument/hover'] =
  vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })

-- rounded border for signature popups
vim.lsp.handlers['textDocument/signatureHelp'] =
  vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

-- when an lsp returns multiple "goto definition" results, only keep the
-- first one
local origTextDocDef = vim.lsp.handlers['textDocument/definition']
vim.lsp.handlers['textDocument/definition'] = function(err, result, ctx, config)
  if result ~= nil and #result > 1 then
    result = { result[1] }
  end
  origTextDocDef(err, result, ctx, config)
end

-- local servers = {
--   'angularls',
--   'basedpyright',
--   'cssls',
--   'denols',
--   'eslint',
--   'html',
--   'intelephense',
--   'jdtls',
--   'jsonls',
--   'ltex_plus',
--   'lua_ls',
--   'ruff',
--   'rust_analyzer',
--   'svelte',
--   'tailwindcss',
--   -- 'ts_ls',
--   'vtsls',
--   'yamlls',
-- }
--
-- for _, server in ipairs(servers) do
--   local config = require('lspconfig.configs.' .. server).default_config
--
--   if not vim.fn.executable(config.cmd[1]) then
--     vim.notify(
--       'Not setting up '
--         .. server
--         .. ' because '
--         .. config.cmd[1]
--         .. ' is not installed',
--       vim.log.levels.WARN
--     )
--   else
--     config.capabilities =
--       require('blink.cmp').get_lsp_capabilities(config.capabilities)
--     require('user.lsp.' .. server).setup(config, server)
--   end
-- end
