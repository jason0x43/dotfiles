local C = require('user.util.lsp').make_config()

C.root_dir = function(bufnr, on_dir)
  if require('user.util.lsp').get_deno_root(bufnr) then
    return
  end

  local file = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(file, { 'tsconfig.json', 'jsconfig.json' })
  if root then
    on_dir(root)
  end
end


C.handlers = {
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
}

C.on_attach = function(client, bufnr)
  -- disable formatting in favor of conform
  client.server_capabilities.documentFormattingProvider = false

  vim.api.nvim_buf_create_user_command(bufnr, 'OrganizeImports', function()
    require('user.util.lsp').organize_imports(bufnr)
  end, { desc = 'Organize imports' })

  -- use angular LS for renames
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'angularls' })
  if #clients > 0 then
    client.server_capabilities.renameProvider = false
  end
end

-- C.should_start = function(file)
--   local denols = require('user.lsp.denols')
--   if denols.should_start(file) then
--     return false
--   end
--
--   return true
-- end

return C
