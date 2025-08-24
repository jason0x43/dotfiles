---@type vim.lsp.Config
local config = {
  -- Update the server config when a new root directory is detected
  settings = {
    java = {
      symbols = {
        includeSourceMethodDeclarations = true,
      },
    },
  },

  handlers = {
    ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
      ---@param diag vim.Diagnostic
      result.diagnostics = vim.tbl_filter(function(diag)
        -- Ignore diagnostic 16, which is "x is a non-project file"
        if diag.code == '16' then
          print(diag.message)
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
}

vim.lsp.config('jdtls', config)
