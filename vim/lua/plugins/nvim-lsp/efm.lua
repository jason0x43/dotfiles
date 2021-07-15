local util = require('util')

local exports = {}

if vim.fn.executable('eslint_d') == 0 then
  print('WARNING: Missing eslint_d')
end

if vim.fn.executable('prettier') == 0 then
  print('WARNING: Missing prettier')
end

if vim.fn.executable('stylua') == 0 then
  print('WARNING: Missing stylua')
end

local eslint = {
  lintCommand = 'eslint_d -f unix --stdin --stdin-filename ${INPUT}',
  lintStdin = true,
  lintIgnoreExitCode = true,
}

local prettier = { formatCommand = 'prettier' }

local stylua = {
  formatCommand = 'stylua --stdin-filepath ${INPUT} --search-parent-directories -',
  formatStdin = true,
}

local js_langs = {}
for _, v in ipairs(util.ts_types) do
  js_langs[v] = { eslint, prettier }
end

exports.config = {
  filetypes = vim.list_extend({
    'markdown',
    'html',
    'lua',
  }, util.ts_types),

  init_options = { documentFormatting = true },

  settings = {
    rootMarkers = { '.git/' },
    languages = vim.tbl_extend('error', {
      markdown = { prettier },
      html = { prettier },
      lua = { stylua },
    }, js_langs),
  },
}

return exports
