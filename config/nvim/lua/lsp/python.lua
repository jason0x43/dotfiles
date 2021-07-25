local exports = {}

function exports.on_attach()
  require('util').cmd('OrganizeImports', '-buffer', 'PyrightOrganizeImports')
end

-- filter out 'is not accessed' hints
-- the '_*' parameters are unused by nvim's default handler (for now)
local function on_publish_diagnostics(_a, _b, params, client_id, _c, config)
  local diags = {}
  for _, v in ipairs(params.diagnostics) do
    if
      v.tags == nil
      or not vim.tbl_contains(v.tags, 1)
      or not v.message:find('is not accessed$')
    then
      table.insert(diags, v)
    end
  end

  vim.lsp.diagnostic.on_publish_diagnostics(
    _a,
    _b,
    vim.tbl_extend('force', params, { diagnostics = diags }),
    client_id,
    _c,
    config
  )
end

exports.config = {
  handlers = {
    ['textDocument/publishDiagnostics'] = on_publish_diagnostics,
  },
}

return exports
