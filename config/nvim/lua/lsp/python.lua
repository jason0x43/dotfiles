local exports = {}

function exports.on_attach()
  require('util').cmd('OrganizeImports', '-buffer', 'PyrightOrganizeImports')
end

local lsp = vim.lsp
local orig_on_publish_diagnostics =
  lsp.handlers['textDocument/publishDiagnostics']

-- filter out 'is not accessed' hints
local function on_publish_diags(err, method, result, client_id, bufnr, config)
  local diags = {}
  for _, v in ipairs(result.diagnostics) do
    if
      v.tags == nil
      or not vim.tbl_contains(v.tags, 1)
      or not v.message:find('is not accessed$')
    then
      table.insert(diags, v)
    end
  end

  orig_on_publish_diagnostics(
    err,
    method,
    vim.tbl_extend('force', result, { diagnostics = diags }),
    client_id,
    bufnr,
    config
  )
end

exports.config = {
  handlers = {
    ['textDocument/publishDiagnostics'] = on_publish_diags,
  },
}

return exports
