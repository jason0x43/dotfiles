local M = {}

local denols = require('lspconfig.server_configurations.denols')

M.config = {
  single_file_support = true,

  init_options = {
    lint = true,
    unstable = true,
  },

  should_attach = function()
    return vim.fn.findfile('deps.ts', '.;') ~= ''
      or vim.fn.findfile('mod.ts', '.;') ~= ''
      or (
        vim.fn.findfile('tsconfig.json', '.;') == ''
        and vim.fn.findfile('jsconfig.json', '.;') == ''
      )
  end,

  handlers = {
    ['textDocument/definition'] = function(err, result, ctx, config)
      -- If denols returns multiple results, goto the first local one
      if result and #result > 1 then
        result = { result[1] }
      end
      denols.default_config.handlers['textDocument/definition'](
        err,
        result,
        ctx,
        config
      )
    end,
  },
}

return M
