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
      eslint_enable_diagnostics = true,
      eslint_disable_if_no_config = true,
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

local lsp_util = require('lspconfig.util')

exports.config = {
  autostart = false,
  handlers = {
    ['textDocument/definition'] = lsp_util.compat_handler(
      function(err, result, ctx)
        -- If tsserver returns multiple results, ignore all but the first
        if #result > 1 then
          result = { result[1] }
        end
        if ctx.is_legacy_call then
          vim.lsp.handlers['textDocument/definition'](err, ctx.method, result)
        else
          vim.lsp.handlers['textDocument/definition'](err, result, ctx)
        end
      end
    ),
  },
}

function exports.check_start()
  -- start the TS server if there's a tsconfig
  if
    vim.fn.findfile('tsconfig.json', '.;') ~= ''
    or vim.fn.findfile('jsconfig.json', '.;') ~= ''
  then
    require('lspconfig').typescript.autostart()
  end
end

local ts_types_str = table.concat(util.ts_types, ',')
util.augroup('init_typescript', {
  'FileType ' .. ts_types_str .. ' lua require("lsp.typescript").check_start()',
})

return exports
