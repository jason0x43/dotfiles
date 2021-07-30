local util = require('util')
local exports = {}

function exports.organize_imports()
  vim.lsp.buf.execute_command({
    command = '_typescript.organizeImports',
    arguments = { vim.fn.expand('%:p') },
  })
end

function exports.on_attach(client)
  -- disable formatting for typescript; we'll use prettier instead
  client.resolved_capabilities.document_formatting = false

  local status, ts_utils = pcall(require, 'nvim-lsp-ts-utils')
  if status then
    ts_utils.setup({
      enable_formatting = true,
      formatter = 'prettierd',
      eslint_enable_diagnostics = true,
      eslint_enable_disable_comments = true,
      eslint_bin = 'eslint_d',
      require_confirmation_on_move = true,
      update_imports_on_move = true,
    })

    ts_utils.setup_client(client)
  end

  util.lmap('R', '<cmd>TSLspRenameFile<cr>')
  util.cmd('OrganizeImports', '-buffer', 'TSLspOrganizeSync')
end

exports.config = {
  autostart = false,
}

function exports.check_start()
  -- start the TS server if there's a tsconfig
  if vim.fn.findfile('tsconfig.json', '.;') ~= '' then
    require('lspconfig').typescript.autostart()
  end
end

local ts_types_str = table.concat(util.ts_types, ',')

util.augroup('init_typescript', {
  'FileType ' .. ts_types_str .. ' lua require("lsp.typescript").check_start()',
})

return exports
