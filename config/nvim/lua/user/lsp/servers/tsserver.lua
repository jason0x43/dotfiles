return {
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
    -- disable formatting in favor of conform
    client.server_capabilities.documentFormattingProvider = false

    -- print(vim.inspect(client.server_capabilities))

    -- use angular LS for renames
    if require('user.util.lsp').server_is_available('angularls') then
      local exists = vim.fn.findfile('angular.json', '.;')
      if exists ~= '' then
        client.server_capabilities.renameProvider = false
        -- client.server_capabilities.referencesProvider = false
      end
    end
  end,
}
