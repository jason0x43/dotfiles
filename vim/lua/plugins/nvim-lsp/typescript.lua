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

_G.typescript = exports
return exports
