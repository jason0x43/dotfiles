local lsp_util = require('user.lsp.util')
local M = {}

M.config = {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'hs', 'vim' },
        -- This seems to always generate false positives
        disable = { 'different-requires' },
      },
      workspace = {
        checkThirdParty = false,
      }
    },
  },
}

if vim.fn.executable('stylua') ~= 0 then
  M.config.on_attach = function(client)
    -- disable formatting; we'll use stylua instead
    lsp_util.disable_formatting(client)
  end
end

return M
