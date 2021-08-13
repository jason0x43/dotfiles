local null_ls = require('null-ls')
local helpers = require('null-ls.helpers')

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

local htmlhint_source = {
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { 'html' },
}

htmlhint_source.generator = helpers.generator_factory({
  command = 'htmlhint',
  args = { '$FILENAME', '--format', 'compact', '--nocolor' },
  to_stdin = false,
  to_temp_file = true,
  to_stderr = true,
  format = 'line',
  ignore_errors = true,
  on_output = function(line)
    if line == '' then
      return nil
    end

    local file, row, col, level, message, str, reason = string.match(
      line,
      '^(.-): line (%d+), col (%d+), (%a+) - (.-) %[ (.-) ].-(.-)$'
    )

    if file == nil then
      return nil
    end

    local severity
    if level == 'error' then
      severity = 1
    else
      severity = 3
    end

    return {
      row = tonumber(row),
      col = tonumber(col),
      end_col = tonumber(col) + #str,
      message = message .. ' ' .. reason,
      severity = severity,
    }
  end,
})

-- run null_ls.config to make null-ls available through lspconfig
local config = {
  sources = {
    null_ls.builtins.formatting.prettierd.with({
      -- prettier for TS/JS is managed by nvim-lsp-ts-utils
      filetypes = { 'markdown', 'html', 'json', 'yaml', 'css' },
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
  },
}

if vim.fn.executable('htmlhint') ~= 0 then
  config.sources:insert(htmlhint_source)
end

null_ls.config(config)

require('lsp').setup_server('null-ls')
