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
      lua = { stylua },
    },
  },
}

return exports
