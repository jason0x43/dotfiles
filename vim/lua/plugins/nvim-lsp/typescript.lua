local util = require('util')
local exports = {}

function exports.organize_imports()
  vim.lsp.buf.execute_command(
      {
        command = '_typescript.organizeImports',
        arguments = { vim.fn.expand('%:p') }
      }
  )
end

function exports.on_attach(client)
  util.cmd(
      'OrganizeImports', '-buffer',
      '<cmd>call v:lua.typescript.organize_imports()<cr>'
  )

  -- disable formatting for typescript; we'll use prettier instead
  client.resolved_capabilities.document_formatting = false
end

exports.config = {
  autostart = false
}

function exports.check_start()
  -- start the TS server if there's a tsconfig
  if vim.fn.findfile('tsconfig.json', '.;') ~= '' then
    require('lspconfig').typescript.autostart()
  end
end

util.augroup('init_typescript', {
  'FileType ' .. util.ts_types .. ' lua typescript.check_start()'
})

_G.typescript = exports
return exports
