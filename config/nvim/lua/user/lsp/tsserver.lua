local lspconfig = require('lspconfig')
local lsp_util = require('user.lsp.util')

local M = {}

M.config = {
  autostart = false,
  root_dir = lspconfig.util.root_pattern('tsconfig.json', 'jsconfig.json'),

  handlers = {
    ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
      result.diagnostics = vim.tbl_filter(function(diag)
        -- ignore 80001 (file is a CommonJS module)
        if diag.code == 80001 then
          return false
        end
        -- ignore 80006 (this can be converted to an async function)
        if diag.code == 80006 then
          return false
        end
        return true
      end, result.diagnostics)

      vim.lsp.handlers['textDocument/publishDiagnostics'](
        err,
        result,
        ctx,
        config
      )
    end,
  },

  on_attach = function(client)
    if vim.fn.executable('prettier') then
      -- disable formatting; we'll use prettier instead
      lsp_util.disable_formatting(client)
    end

    require('user.util').bufcmd('OrganizeImports', 'TsserverOrganizeImports')
  end,

  commands = {
    TsserverOrganizeImports = {
      function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.lsp.buf.execute_command({
          command = '_typescript.organizeImports',
          arguments = { vim.api.nvim_buf_get_name(bufnr) },
        })
      end,
      description = 'Organize imports',
    },
  },
}

M.start = lsp_util.create_start('tsserver')

lsp_util.create_autostart_autocmd('tsserver', require('user.util').ts_types)

return M
