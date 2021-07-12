local exports = {}

if vim.fn.executable('eslint_d') == 0 then
  print('WARNING: Missing eslint_d')
end

if vim.fn.executable('prettier') == 0 then
  print('WARNING: Missing prettier')
end

if vim.fn.executable('lua-format') == 0 then
  print('WARNING: Missing lua-format')
end

local eslint = {
  lintCommand = 'eslint_d -f unix --stdin --stdin-filename ${INPUT}',
  lintStdin = true,
  lintIgnoreExitCode = true
}

local prettier = { formatCommand = 'prettier' }

local lua_opts = {
  '-i',
  '--column-limit=80',
  '--continuation-indent-width=2',
  '--indent-width=2',
  '--no-align-args',
  '--no-align-parameter',
  '--break-after-functiondef-lp',
  '--break-before-functiondef-rp',
  '--break-after-functioncall-lp',
  '--break-before-functioncall-rp',
  '--chop-down-parameter',
  '--chop-down-table',
  '--double-quote-to-single-quote',
  '--no-keep-simple-control-block-one-line',
  '--no-keep-simple-function-one-line',
  '--spaces-around-equals-in-field',
  '--spaces-inside-table-braces'
}

local lua_format = {
  formatCommand = 'lua-format ' .. table.concat(lua_opts, ' '),
  formatStdin = true
}

exports.config = {
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'markdown',
    'html',
    'lua',
  },

  init_options = { documentFormatting = true },

  settings = {
    rootMarkers = { '.git/' },
    languages = {
      javascript = { eslint, prettier },
      javacriptreact = { eslint, prettier },
      typescript = { eslint, prettier },
      typecriptreact = { eslint, prettier },
      markdown = { prettier },
      html = { prettier },
      lua = { lua_format }
    }
  }
}

return exports
