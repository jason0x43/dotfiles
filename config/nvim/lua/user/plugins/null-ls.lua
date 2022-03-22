local M = {}

M.config = function()
  local null_ls = require('user.req')('null-ls')
  if not null_ls then
    return
  end

  local lsp_on_attach = require('user.lsp').on_attach

  local helpers = require('null-ls.helpers')

  local htmlhint_source = {
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = { 'html' },
    generator = helpers.generator_factory({
      command = 'htmlhint',
      args = { '--format', 'json', '--nocolor', 'stdin' },
      format = 'json',
      to_stdin = true,
      check_exit_code = { 0, 1 },
      on_output = function(params)
        if params.output == nil then
          return nil
        end

        local results = {}

        for _, err in ipairs(params.output) do
          for _, msg in ipairs(err.messages) do
            local severity
            if msg.type == 'error' then
              severity = 1
            else
              severity = 3
            end

            table.insert(results, {
              row = msg.line,
              col = msg.col,
              end_col = msg.col + #msg.evidence,
              message = msg.message .. ' (' .. msg.rule.id .. ')',
              severity = severity,
            })
          end
        end

        return results
      end,
    }),
  }

  -- run null_ls.config to make null-ls available through lspconfig
  local config = {
    sources = {
      null_ls.builtins.formatting.prettier.with({
        filetypes = vim.list_extend(
          { 'xml' },
          null_ls.builtins.formatting.prettier.filetypes
        ),
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
      null_ls.builtins.formatting.swiftformat,
    },

    on_attach = lsp_on_attach,
  }

  if vim.fn.executable('htmlhint') ~= 0 then
    table.insert(config.sources, htmlhint_source)
  end

  null_ls.setup(config)
end

return M
