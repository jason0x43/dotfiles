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

  local ts_utils = require('nvim-lsp-ts-utils')

  ts_utils.setup({
    enable_formatting = true,
    eslint_enable_diagnostics = true,
    require_confirmation_on_move = true,
    update_imports_on_move = true,
  })

  ts_utils.setup_client(client)

  util.keys.lmap('R', '<cmd>TSLspRenameFile<cr>')
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
  'FileType ' .. ts_types_str .. ' lua typescript.check_start()',
})

_G.typescript = exports
return exports
