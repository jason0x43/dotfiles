local denols = require('lsp.denols')

local M = {}

M.config = {
  handlers = {
    ['textDocument/definition'] = function(err, result, ctx)
      -- If tsserver returns multiple results, ignore all but the first
      if #result > 1 then
        result = { result[1] }
      end
      vim.lsp.handlers['textDocument/definition'](err, result, ctx)
    end,
  },

  on_attach = function(client)
    -- disable formatting for typescript; we'll use prettier instead
    client.resolved_capabilities.document_formatting = false

    require('util').bufcmd('OrganizeImports', 'TsserverOrganizeImports')
  end,

  should_attach = function()
    return not denols.config.should_attach()
  end,

  commands = {
    TsserverOrganizeImports = {
      function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.lsp.buf.execute_command({
          command = '_typescript.organizeImports',
          arguments = { vim.api.nvim_buf_get_name(bufnr) },
        })
      end,
      description = 'Organize imports',
    },
  },
}

return M
