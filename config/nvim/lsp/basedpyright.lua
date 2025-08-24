---@type vim.lsp.Config
local config = {
  on_attach = function(client)
    -- Let neovim know about custom basedpyright commands that may be used by
    -- code actions
    local provider = client.server_capabilities.executeCommandProvider
    if provider then
      provider.commands = vim.tbl_extend('keep', provider.commands, {
        'basedpyright.createtypestub',
      })
    end
  end,

  handlers = {
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
  },
}

vim.lsp.config('basedpyright', config)
