local M = {}

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
      if #result > 1 then
        result = { result[1] }
      end
      vim.lsp.handlers['textDocument/definition'](err, result, ctx, config)
    end,
  },
}

return M
