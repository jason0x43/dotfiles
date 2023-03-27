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
    -- disable formatting in favor of null_ls
    client.server_capabilities.documentFormattingProvider = false

    vim.api.nvim_buf_create_user_command(0, 'OrganizeImports', function()
      vim.lsp.buf.execute_command({
        command = '_typescript.organizeImports',
        arguments = { vim.api.nvim_buf_get_name(0) },
      })
    end, {})
  end,
}
