local null_ls = require('null-ls')

-- run null_ls.config to make null-ls available through lspconfig
null_ls.config({
  sources = {
    null_ls.builtins.formatting.prettierd.with({
        -- prettier for TS/JS is managed by nvim-lsp-ts-utils
        filetypes = { 'markdown', 'html', 'json', 'yaml' },
      }),

    null_ls.builtins.formatting.stylua.with({
        args = {
          '--stdin-filepath',
          '$FILENAME',
          '--search-parent-directories',
          '-',
        },
      }),

    null_ls.builtins.formatting.black,

    -- null_ls.builtins.diagnostics.vale,
  },
})

local lsp = vim.lsp
local orig_on_publish_diagnostics =
  lsp.handlers['textDocument/publishDiagnostics']

-- filter out 'No ESLint configuration' errors
lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(
  function(err, method, result, client_id, bufnr, config)
    local diags = {}
    for _, v in ipairs(result.diagnostics) do
      if
        v.source ~= 'eslint'
        or not v.message:find('No ESLint configuration found')
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
  end,
  {}
)

local exports = {}

exports.config = {}

return exports
