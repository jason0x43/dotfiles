local util = require('util')
local M = {}

function M.organize_imports()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.buf.execute_command({
    command = '_typescript.organizeImports',
    arguments = { vim.api.nvim_buf_get_name(bufnr) },
  })
end

function M.on_attach(client)
  -- disable formatting for typescript; we'll use prettier instead
  client.resolved_capabilities.document_formatting = false
  util.cmd(
    'OrganizeImports',
    '-buffer',
    'lua require("lsp.tsserver").organize_imports()'
  )
end

local lsp_util = require('lspconfig.util')

M.config = {
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

function M.check_start()
  -- start the TS server if there's a tsconfig
  if
    vim.fn.findfile('tsconfig.json', '.;') ~= ''
    or vim.fn.findfile('jsconfig.json', '.;') ~= ''
  then
    require('lspconfig').tsserver.autostart()
  end
end

local ts_types_str = table.concat(util.ts_types, ',')
util.augroup('init_typescript', {
  'FileType ' .. ts_types_str .. ' lua require("lsp.tsserver").check_start()',
})

return M
