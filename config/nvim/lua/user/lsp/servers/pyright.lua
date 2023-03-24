return {
  config = {
    on_attach = function()
      vim.api.nvim_buf_create_user_command(
        0,
        'OrganizeImports',
        'PyrightOrganizeImports',
        {}
      )
    end,

    handlers = {
      ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
        if vim.fn.getenv('PYRIGHT_HIDE_HINTS') == '1' then
          result.diagnostics = vim.tbl_filter(function(diag)
            -- ignore 'not accessed' diags
            if diag.tags and diag.tags[1] ~= nil then
              return false
            end
            return true
          end, result.diagnostics)
        end

        vim.lsp.handlers['textDocument/publishDiagnostics'](
          err,
          result,
          ctx,
          config
        )
      end,
    },
  },
}
