local C = require('user.util.lsp').make_user_config()

C.config.handlers = {
  ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
    result.diagnostics = vim.tbl_filter(function(diag)
      -- ignore 'not accessed' diags
      if diag.tags and diag.tags[1] ~= nil then
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
}

return C
