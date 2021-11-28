local denols = require('lsp.denols')

local M = {}

M.config = {
  handlers = {
    ['textDocument/definition'] = function(err, result, ctx, config)
      -- If tsserver returns multiple results, ignore all but the first
      if #result > 1 then
        result = { result[1] }
      end
      vim.lsp.handlers['textDocument/definition'](err, result, ctx, config)
    end,

    ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
      result.diagnostics = vim.tbl_filter(function (diag)
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
    -- disable formatting for typescript; we'll use prettier instead
    client.resolved_capabilities.document_formatting = false

    require('util').bufcmd('OrganizeImports', 'TsserverOrganizeImports')
  end,

  should_attach = function()
    return not denols.config.should_attach()
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

return M
