local exports = {}

function exports.setup()
  local null_ls = require('null-ls')
  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.prettierd.with({
        -- prettier for TS/JS is managed by nvim-lsp-ts-utils
        filetypes = { 'markdown', 'html', 'json', 'yaml' },
      }),
      null_ls.builtins.formatting.stylua.with({
        arguments = {
          '--stdin-filepath',
          '$FILENAME',
          '--search-parent-directories',
          '-',
        },
      }),
    },
    on_attach = require('lsp').on_attach,
  })
end

return exports
